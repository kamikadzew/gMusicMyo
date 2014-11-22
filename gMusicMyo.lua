scriptId = 'com.kamikadzew.gMusicMyo'
--Helper functions
ENABLED_TIMEOUT = 2200
ROLL_SENS = 0.25

function conditionallySwapWave(pose)
    if myo.getArm() == "left" then
        if pose == "waveIn" then
            pose = "waveOut"
        elseif pose == "waveOut" then
            pose = "waveIn"
        end
    end
    return pose
end

--Control Functions
function waveInAction()
    --myo.debug("WaveIn")
    myo.keyboard("left_arrow","press")
	myo.vibrate("short")
end
function waveOutAction()
    --myo.debug("WaveOut")
    myo.keyboard("right_arrow","press")
	myo.vibrate("short")
end
function fingersSpreadAction()
    --myo.debug("fingersSpread")
    myo.keyboard("space","press")
	myo.vibrate("short")
end
function fistAction()
    --myo.debug("fist")
    --PLACEHOLDER:FIST
end
function thumbToPinkyAction()
    unlock()
end
function rollOut()
	 myo.keyboard("equal","press")
end
function rollIn()
	myo.keyboard("minus","press")
end	
--Unlock Functions
function unlock()
    local now = myo.getTimeMilliseconds()

    if myo.practice then
        myo.notifyEffect("unlock")
    end

    enabled = true
    enabledSince = now
end

function extendUnlock()
    local now = myo.getTimeMilliseconds()

    if myo.practice then
        myo.notifyEffect("extendUnlock")
    end

    enabledSince = now
end


function onPoseEdge(pose, edge)
    pose=conditionallySwapWave(pose)
    local now = myo.getTimeMilliseconds()

    if pose == "thumbToPinky" then
        if edge == "off" then
            unlock()
        elseif edge == "on" and not enabled then
            -- Vibrate twice on unlock
            myo.vibrate("short")
            myo.vibrate("short")
        end
    end
    
    if edge == "on" and enabled then
        if pose == "waveIn" and enabled then
            waveInAction()
            extendUnlock()
        elseif pose == "waveOut" and enabled then
            waveOutAction()
            extendUnlock()
        --elseif pose == "fist" and enabled then
           -- fistAction()    
           -- extendUnlock()
        elseif pose == "fingersSpread" and enabled  then
            fingersSpreadAction()
            extendUnlock()
        end
    end
	if enabled and pose=="fist" then
		if edge=="on" then
			--myo.debug("YesFist")
			fistMade=true
			referenceRoll=currentRoll
		elseif edge=="off" then
			--myo.debug("NoFist")
			fistMade=false
		end
	end
end

vel=0
-- onPeriodic runs every ~10ms
function onPeriodic()
    local now = myo.getTimeMilliseconds()
    if enabled then
        if (now - enabledSince) > ENABLED_TIMEOUT then
            enabled = false
            -- Vibrate once on lock
            myo.vibrate("short")
        end
    end

	
	
	    currentRoll = myo.getRoll()
    if myo.getXDirection() == "towardElbow" and fistMade then
        currentRoll = -currentRoll
        extendUnlock()
    end

    if enabled and fistMade then -- Moves page when fist is held and Myo is rotated
		deltaRoll=currentRoll+referenceRoll
		vel=vel+(math.floor(0.5+(100^math.abs(deltaRoll))))
		--myo.debug(vel)
		--myo.debug(referenceRoll)
		--myo.debug(currentRoll)
		--myo.debug(deltaRoll)
		if vel>200 then
			vel=0
			--myo.debug("Volume Controll")
			extendUnlock()
			if deltaRoll > ROLL_SENS  then
				rollOut()
				--myo.debug("+")
			elseif deltaRoll < -ROLL_SENS then
				rollIn() 
				--myo.debug("-")
			end
		end
    end
	
	
end

-- Only activate when using correct application
function onForegroundWindowChange(app, title)
    --enabled = true
	--extendUnlock()
	--myo.debug(title)
    if string.match(title, " *Google Play Music %- Google Chrome$") then
        --unlock()
		--myo.debug("app")
        return true
    end
end
