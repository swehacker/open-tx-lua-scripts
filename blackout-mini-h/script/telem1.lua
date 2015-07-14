-- ###############################################################
-- #                                                             #
-- #  Telemetry Lua Script naze32                                #
-- #                                                             #
-- #  + naze32 telemetry enabled                                 #
-- #  + tested with D4r-II                                       #
-- #                                                             #
-- #  License (Script & images): Share alike                     #
-- #  Can be used and changed non commercial	                 #
-- #                                                             #
-- #  Inspired by SockEye, Richardoe, Schicksie, lichtl          #
-- #  								                             #
-- #  Modified by Patrik Falk, http://www.swehacker.com          #
-- #                                                             #
-- ###############################################################

local function run(event)

    -- ###############################################################
    -- Low Battery Warning Voltages
    -- ###############################################################

    local four_low = 13.5 -- 4s Battery
    local three_low = 10.2 -- 3s Battery
    local two_low = 6.9 -- 2s Battery

    -- ###############################################################
    -- Full Battery Voltages
    -- ###############################################################

    local four_high = 16.5 -- 4s Battery
    local three_high = 12.5 -- 3s Battery
    local two_high = 8.5 -- 2s Battery

    -- ###############################################################
    -- Setup number of cells of the battery and image
    -- ###############################################################

    local battype = 3
    local battypestr = "_S"
    local percent = 0
    local batt_sum = getValue("cell-sum")
    if batt_sum > 3 then
        battype = math.ceil(batt_sum / 4.25)
        if battype == 4 then
            battypestr = "4S"
            percent = (batt_sum - four_low) * (100 / (four_high - four_low))
        end
        if battype == 3 then
            battypestr = "3S"
            percent = (batt_sum - three_low) * (100 / (three_high - three_low))
        end
        if battype == 2 then
            battypestr = "2S"
            percent = (batt_sum - two_low) * (100 / (two_high - two_low))
        end
    end

    local myPxHeight = math.floor(percent * 0.37)
    local myPxY = 11 + 37 - myPxHeight

    lcd.drawPixmap(3, 1, "/SCRIPTS/BMP/battery.bmp")

    if percent > 0 then
        lcd.drawFilledRectangle(8, myPxY, 21, myPxHeight, FILL_WHITE)
    end

    local i = 36
    while (i > 0) do
        lcd.drawLine(7, 11 + i, 27, 11 + i, SOLID, GREY_DEFAULT)
        i = i - 2
    end

    if (percent < 15) then
        lcd.drawNumber(4, 55, batt_sum * 100, PREC2 + LEFT + BLINK)
    else
        lcd.drawNumber(4, 55, batt_sum * 100, PREC2 + LEFT)
    end
    lcd.drawText(lcd.getLastPos(), 55, "v ", 0)
    lcd.drawText(lcd.getLastPos(), 55, battypestr, 0)

    -- ###############################################################
    -- Timer
    -- ###############################################################

    local timer = model.getTimer(0)
    lcd.drawText(98, 40, "Timer:", SMLSIZE, 0)
    lcd.drawTimer(133, 36, timer.value, MIDSIZE)

    -- ###############################################################
    -- Clock
    -- ###############################################################

    lcd.drawTimer(38, 3, getValue(190), LEFT + MIDSIZE)

    -- ###############################################################
    -- Throttle in %
    -- ###############################################################

    function round(num, idp)
        local mult = 10 ^ (idp or 0)
        return math.floor(num * mult + 0.5) / mult
    end

    lcd.drawText(98, 26, "THR %: ", SMLSIZE, 0)
    lcd.drawText(133, 22, round((getValue(MIXSRC_Thr) / 10.24) / 2 + 50, 0), MIDSIZE, 0)

    -- ###############################################################
    -- Flightmode image
    -- ###############################################################

    lcd.drawPixmap(83, 1, "/SCRIPTS/BMP/fm.bmp")

    -- ###############################################################
    -- Flightcontrol	DISARMED/ARMED/BEEPER				switch SD
    -- ###############################################################

    if getValue(MIXSRC_SD) < 0 then -- switch SF
    lcd.drawText(38, 26, "FC DISARMED", SMLSIZE)
    lcd.drawText(38, 40, "BEEPER OFF", SMLSIZE)
    elseif getValue(MIXSRC_SD) == 0 then
        lcd.drawText(38, 26, "FC ARMED", SMLSIZE)
        lcd.drawText(38, 40, "BEEPER OFF", SMLSIZE)
    else
        lcd.drawText(38, 26, "FC DISARMED", SMLSIZE)
        lcd.drawText(38, 40, "BEEPER ON", SMLSIZE)
    end

    -- ###############################################################
    -- Flightmode1		Angle/Horizon/Acro					switch SE
    -- ###############################################################

    if getValue(MIXSRC_SE) < 0 then
        lcd.drawText(98, 3, "Angle", MIDSIZE)
    elseif getValue(MIXSRC_SE) == 0 then
        lcd.drawText(98, 3, "Horizon", MIDSIZE)
    else
        lcd.drawText(98, 3, "Acro", MIDSIZE)
    end

    -- ###############################################################
    -- Displays xyz data
    -- ###############################################################

    lcd.drawText(60, 55, "x:", SMLSIZE, 0)
    lcd.drawText(70, 55, getValue("accx"), 0)

    lcd.drawText(95, 55, "y:", SMLSIZE, 0)
    lcd.drawText(105, 55, getValue("accy"), 0)

    lcd.drawText(130, 55, "z:", SMLSIZE, 0)
    lcd.drawText(145, 55, getValue("accz"), 0)


    -- ###############################################################
    -- Displays RSSI data
    -- ###############################################################

    if getValue("rssi") > 38 then
        percent = ((math.log(getValue("rssi") - 28, 10) - 1) / (math.log(72, 10) - 1)) * 100
    else
        percent = 0
    end

    if percent > 90 then
        lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI10.bmp")
    elseif percent > 80 then
        lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI09.bmp")
    elseif percent > 70 then
        lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI08.bmp")
    elseif percent > 60 then
        lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI07.bmp")
    elseif percent > 50 then
        lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI06.bmp")
    elseif percent > 40 then
        lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI05.bmp")
    elseif percent > 30 then
        lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI04.bmp")
    elseif percent > 20 then
        lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI03.bmp")
    elseif percent > 10 then
        lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI02.bmp")
    elseif percent > 0 then
        lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI01.bmp")
    else
        lcd.drawPixmap(164, 1, "/SCRIPTS/BMP/RSSI00.bmp")
    end

    lcd.drawChannel(178, 55, 200, LEFT)
    lcd.drawText(lcd.getLastPos(), 56, "dB", SMLSIZE)
end

return { run = run }
