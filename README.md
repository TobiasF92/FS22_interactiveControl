# Interactive Control

'Interactive Control' is a global script mod for Farming Simulator 22.
While this mod is active, you are able to use many other mods that support Interactive Control.
With IC you have the possibility to interactively control many parts of several (prepared) vehicles. to use many other mods that support Interactive Control. With IC you have the possibility to interactively control many parts of several (prepared) vehicles.

Possibilities


## Possibilities

'Interactive Control' provides different possibilities to interact with your vehicles. You can use click icons that appear when you turn on IC or when you are nearby. Another way for interactive handling is a key binding event. The controls are able to be used as switch or to force a state.
All interactions are generally possible to use from the inside and the outside of a vehicle. 

Using the controls you can steer different things:
* Play animations (e.g. to open/close windows, fold/unfold warning signs, ...)
* Call specific [functions](#FunctionOverview) (e.g. Start/Stop Motor, TurnOn/Off tool, Lift/Lower attacher joints, ...)
* ObjectChanges (to change translation/rotation/visibility/...)

## Thanks goes to:
***Wopster, JoPi, SirJoki80 & Flowsen (for the ui elements) and Face (for the initial idea)***

***VertexDezign & SchnibblModding for testing and providing demo mods!***



## Documentation

The documentation is not finished yet, but should be sufficient for experienced users.
If you are in need of some extra help, take a look into the demonstration mods:
* Fendt Vario 900 Gen 6 / Gen 7
  * Modhub: https://farming-simulator.com/mod.php?mod_id=225936
* Kerner Corona Pack
  * Modhub: https://farming-simulator.com/mod.php?mod_id=251288
* Faresin 6.26
  * Modhub: https://farming-simulator.com/mod.php?mod_id=258842


### XML

Explained XML documentation [HTML-file](documentation/interactiveControl.html)
```xml
<interactiveControl>
    <interactiveControlConfigurations>
        <!-- If needed, you can define different configurations -->
        <interactiveControlConfiguration>
            <interactiveControls>
                <!-- The outdoor trigger is important, if you want to use IC from the outside of a vehicle -->
                <outdoorTrigger node="node"/>
                
                <!-- Add a new Interactive Control -->
                <interactiveControl negText="$l10n_actionIC_deactivate" posText="$l10n_actionIC_activate">
                    <!-- Add a clickPoint to toggle the event -->
                    <!-- Possible iconTypes: -->
                    <!-- CROSS, IGNITIONKEY, CRUISE_CONTROL, GPS, TURN_ON, ATTACHERJOINT_LOWER, ATTACHERJOINT_LIFT, ATTACHERJOINT, LIGHT_HIGH, LIGHT, TURNLIGHT_LEFT, TURNLIGHT_RIGHT, BEACON_LIGHT, ARROW -->
                    <clickPoint alignToCamera="true" animMaxLimit="1" animMinLimit="0" animName="string" blinkSpeedScale="1" foldMaxLimit="1" foldMinLimit="0" forcedState="boolean" iconType="CROSS" invertX="false" invertZ="false" node="node" scaleOffset="float" size="0.04" type="UNKNOWN"/>
                 
                    <!-- Add a button to toggle the event -->
                    <button animMaxLimit="1" animMinLimit="0" animName="string" foldMaxLimit="1" foldMinLimit="0" forcedState="boolean" input="string" range="5" refNode="node" type="UNKNOWN"/>

                    <!-- Animation to be played on IC event -->
                    <animation initTime="float" name="string" speedScale="float" />

                    <!-- Add a function to your control, don't forget to add a attacherJoint index (or indicies) if required! -->
                    <function name="string">
                        <attacherJoint index="integer" indicies="1 2 .. n"/>
                    </function>

                    <!-- This control should not be functional all the time? Add a configuration restriction -->
                    <configurationsRestrictions>
                        <restriction indicies="1 2 .. n" name="string"/>
                    </configurationsRestrictions>
                    
                    <!-- You want to use some extra dashboards for your control? -->
                    <!-- There are three new valueTypes: ic_state (BOOLEAN) | ic_stateValue (FLOAT 0-1) | ic_action (in combination with 'raiseTime', 'activeTime', 'onICActivate', 'onICDeactivate')-->
                    <dashboard activeTime="1" animName="string" baseColor="string" displayType="string" doInterpolation="false" emissiveScale="0.2" emitColor="string"font="DIGIT" fontThickness="1" groups="string" hasNormalMap="false" hiddenColor="string" idleValue="0" intensity="1" interpolationSpeed="0.005" maxRot="string" maxValueAnim="float" maxValueRot="float" maxValueSlider="float" minRot="string" minValueAnim="float" minValueRot="float" minValueSlider="float" node="node" numberColor="string" numbers="node" onICActivate="true" onICDeactivate="true" precision="1" raiseTime="1" rotAxis="float" textAlignment="RIGHT" textColor="string" textMask="00.0" textScaleX="1" textScaleY="1" textSize="0.03" valueType="string">
                        <state rotation="x y z" scale="x y z" translation="x y z" value="1 2 .. n" visibility="boolean"/>
                    </dashboard>
                    
                    <!-- You can block unused moving parts here -->
                    <dependingMovingPart isInactive="true" node="node"/>

                    <!-- You can block unused moving tools here -->
                    <dependingMovingTool isInactive="true" node="node"/>

                    <!-- You can block depending interactive controls here -->
                    <!-- blockState: Control state to block depending control -->
                    <!-- forcedBlockedState: Forced state of depending control if blocked -->
                    <dependingInteractiveControl index="int" blockState="boolean" forcedBlockedState="boolean"/>
                    
                    <!-- Modify sound here, 'indoorFactor' is the sound percentage factor if control is active -->
                    <!-- Set 'delayedSoundAnimationTime' if the sound should be changed on specific animation time (first animation or 'name') -->
                    <soundModifier indoorFactor="float" delayedSoundAnimationTime="float" name="string"/>
                 
                    <objectChange centerOfMassActive="x y z" centerOfMassInactive="x y z" compoundChildActive="boolean" compoundChildInactive="boolean" interpolation="false" interpolationTime="1" massActive="float" massInactive="float" node="node" parentNodeActive="node" parentNodeInactive="node" rigidBodyTypeActive="string" rigidBodyTypeInactive="string" rotationActive="x y z" rotationInactive="x y z" scaleActive="x y z" scaleInactive="x y z" shaderParameter="string" shaderParameterActive="x y z w" shaderParameterInactive="x y z w" sharedShaderParameter="false" translationActive="x y z" translationInactive="x y z" visibilityActive="boolean" visibilityInactive="boolean"/>
                </interactiveControl>
            </interactiveControls>
            
            <objectChange centerOfMassActive="x y z" centerOfMassInactive="x y z" compoundChildActive="boolean" compoundChildInactive="boolean" interpolation="false" interpolationTime="1" massActive="float" massInactive="float" node="node" parentNodeActive="node" parentNodeInactive="node" rigidBodyTypeActive="string" rigidBodyTypeInactive="string" rotationActive="x y z" rotationInactive="x y z" scaleActive="x y z" scaleInactive="x y z" shaderParameter="string" shaderParameterActive="x y z w" shaderParameterInactive="x y z w" sharedShaderParameter="false" translationActive="x y z" translationInactive="x y z" visibilityActive="boolean" visibilityInactive="boolean"/>
        </interactiveControlConfiguration>
    </interactiveControlConfigurations>
    
    <!-- If you want to use your own click icon, you easily can register it here -->
    <registers>
        <clickIcon blinkSpeed="float" filename="string" name="string" node="string"/>
    </registers>
</interactiveControl>

```


### FunctionOverview:

Function | Description | Requirements | Required Version
-------- | -------- | -------- | --------
MOTOR_START_STOPP | Toggle vehicle motor start and stop
LIGHTS_TOGGLE | Toggle lights on and off
LIGHTS_WORKBACK_TOGGLE | Toggle worklights back on and off
LIGHTS_WORKFRONT_TOGGLE | Toggle worklights front on and off
LIGHTS_HIGHBEAM_TOGGLE | Toggle highbeamlights on and off
LIGHTS_TURNLIGHT_HAZARD_TOGGLE | Toggle hazard lights on and off
LIGHTS_TURNLIGHT_LEFT_TOGGLE | Toggle turnlight left on and off
LIGHTS_TURNLIGHT_RIGHT_TOGGLE | Toggle turnlight right on and off
LIGHTS_BEACON_TOGGLE | Toggle beaconlight on and off
LIGHTS_PIPE_TOGGLE | Toggle pipelight on and off | | 1.1.0.0
CRUISE_CONTROL_TOGGLE | Toggle cruise control on and off
DRIVE_DIRECTION_TOGGLE | Toggle vehicle drive direction
COVER_TOGGLE | Toggle cover state
ATTACHERJOINT_LIFT_LOWER | Lift/lower implement on attacherJoint index or first selected one if more indicies | ".attacherJoint#index" or ".attacherJoint#indicies"
ATTACHERJOINT_TURN_ON_OFF | Turn on/off implement on attacherJoint index or first selected one if more indicies | ".attacherJoint#index"
TURN_ON_OFF | Turn on/off vehicle
ATTACHERJOINT_FOLDING_TOGGLE | Fold/unfold implement on attacherJoint index or first selected one if more indicies | ".attacherJoint#index"
PIPE_FOLDING_TOGGLE | Fold/unfold pipe | | 1.1.0.0
FOLDING_TOGGLE | Fold/unfold vehicle
ATTACHERJOINTS_TOGGLE_DISCHARGE | Toggle discharging on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies"
DISCHARGE_TOGGLE | Toggle discharging on vehicle
CRABSTEERING_TOGGLE | Toggle crab steering mode to next mode
RADIO_TOGGLE | Toggle radio on/off
RADIO_CHANNEL_NEXT | Next radio channel | | 1.1.0.0
RADIO_CHANNEL_PREVIOUS | Previous radio channel | | 1.1.0.0
RADIO_ITEM_NEXT | Next radio item | | 1.1.0.0
RADIO_ITEM_PREVIOUS | Previous radio item | | 1.1.0.0
VARIABLE_WORK_WIDTH_LEFT_INCREASE | Increase work width left | | 1.1.0.0
VARIABLE_WORK_WIDTH_LEFT_DECREASE | Decrease work width left | | 1.1.0.0
ATTACHERJOINTS_VARIABLE_WORK_WIDTH_LEFT_INCREASE | Increase work width left on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
ATTACHERJOINTS_VARIABLE_WORK_WIDTH_LEFT_DECREASE | Decrease work width left on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
VARIABLE_WORK_WIDTH_RIGHT_INCREASE | Increase work width right | | 1.1.0.0
VARIABLE_WORK_WIDTH_RIGHT_DECREASE | Decrease work width right | | 1.1.0.0
ATTACHERJOINTS_VARIABLE_WORK_WIDTH_RIGHT_INCREASE | Increase work width right on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
ATTACHERJOINTS_VARIABLE_WORK_WIDTH_RIGHT_DECREASE | Decrease work width right on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
VARIABLE_WORK_WIDTH_TOGGLE | Toggle work width | | 1.1.0.0
ATTACHERJOINTS_VARIABLE_WORK_WIDTH_TOGGLE | Toggle work width on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
ATTACHERJOINTS_ATTACH_DETACH | Attach or detach vehicle on attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
**External Mods**:
GPS_TOGGLE | Toggle [GuidanceSteering](https://farming-simulator.com/mod.php?mod_id=228522) on and off
PF_CROP_SENSOR_TOGGLE | Toggle [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) crop sensor mode | | 1.1.0.0
PF_ATTACHERJOINTS_CROP_SENSOR_TOGGLE | Toggle [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) crop sensor mode on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
PF_SEED_RATE_MODE | Toggle [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) seed rate mode | | 1.1.0.0
PF_ATTACHERJOINTS_SEED_RATE_MODE | Toggle [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) seed rate mode on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
PF_SEED_RATE_UP | Increase [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) manual seed rate | | 1.1.0.0
PF_SEED_RATE_DOWN | Decrease [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) manual seed rate | | 1.1.0.0
PF_ATTACHERJOINTS_SEED_RATE_UP | Increase [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) manual seed rate on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
PF_ATTACHERJOINTS_SEED_RATE_DOWN | Decrease [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) manual seed rate on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
PF_SPRAY_AMOUNT_MODE | Toggle [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) spray amount mode | | 1.1.0.0
PF_ATTACHERJOINTS_SPRAY_AMOUNT_MODE | Toggle [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) spray amount mode on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
PF_SPRAY_AMOUNT_UP | Increase [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) manual spray amount | | 1.1.0.0
PF_SPRAY_AMOUNT_DOWN | Decrease [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) manual spray amount | | 1.1.0.0
PF_ATTACHERJOINTS_SPRAY_AMOUNT_UP | Increase [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) manual spray amount on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
PF_ATTACHERJOINTS_SPRAY_AMOUNT_DOWN | Decrease [PrecisionFarming](https://farming-simulator.com/mod.php?mod_id=238269) manual spray amount on selected attacherJoint if in 'indices' | ".attacherJoint#index" or ".attacherJoint#indicies" | 1.1.0.0
VCA_TOGGLE_AWD | Toggle [VehicleControlAddon](https://farming-simulator.com/mod.php?mod_id=228601) all wheel drive mode on and off | | 1.1.0.0
VCA_TOGGLE_DIFFLOCK_FRONT | Toggle [VehicleControlAddon](https://farming-simulator.com/mod.php?mod_id=228601) front differential lock on and off | | 1.1.0.0
VCA_TOGGLE_DIFFLOCK_BACK | Toggle [VehicleControlAddon](https://farming-simulator.com/mod.php?mod_id=228601) back differential lock on and off | | 1.1.0.0
VCA_TOGGLE_PARKINGBRAKE | Toggle [VehicleControlAddon](https://farming-simulator.com/mod.php?mod_id=228601) parkingbrake on and off | | 1.1.0.0
HEADLAND_MANAGEMENT_TOGGLE | Toggle [HeadlandManagement](https://farming-simulator.com/mod.php?mod_id=228759) on and off | | 1.1.0.0

## Copyright

Copyright (c) 2022, John Deere 6930. All rights reserved.
