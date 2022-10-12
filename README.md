# Interactive Control

'Interactive Control' is a global script mod for Farming Simulator 22.
While this mod is active, you are able to use several other mods that support Interactive Control.
With IC you get the possibility to control many parts of several (prepared) vehicles interacitvly. 


## Possibilities

'Interactive Control' provides different possibilities to interact with your vehicles. You can use click icons that appear when you turn them on or when you are nearby. Another way to use the functionalities is a key binding event. The controls are able to be used as switch or to force a state.
All interactions are generally possible to use from the inside and the outside of a vehicle. 

Using the controls you can steer different things:
* Play animations (e.g. to open/close windows, fold/unfold warning signs, ...)
* Call specific functions (e.g. Start/Stop Motor, TurnOn/Off tool, Lift/Lower attacher joints, ...)
* Objectchanges (to change translation/rotation/visibility/...)


## Documentation

The documentation is not finished yet, but should be sufficient for experienced users.
If you are in need of some extra help, take a look into the demonstration mods:
* Fendt Vario 900 Gen 6
  * Modhub: 
* Fendt Vario 900 Gen 7
  * Modhub: 
* Kerner Corona Pack
  * Modhub: 


```xml
<interactiveControl>
    <interactiveControlConfigurations>
        <!-- If needed, you can define different configurations -->
        <interactiveControlConfiguration>
            <interactiveControls>
            
                <!-- Add a new Interactive Control -->
                <interactiveControl negText="$l10n_actionIC_deactivate" posText="$l10n_actionIC_activate">
                    <!-- Animation to be played on IC event -->
                    <animation initTime="float" name="string" speedScale="float" />
                    
                    <!-- Add a button to toggle the event -->
                    <button animMaxLimit="1" animMinLimit="0" animName="string" foldMaxLimit="1" foldMinLimit="0" forcedState="boolean" input="string" range="5" refNode="node" type="UNKNOWN"/>
                    
                    <!-- Add a clickPoint to toggle the event -->
                    <clickPoint alignToCamera="true" animMaxLimit="1" animMinLimit="0" animName="string" blinkSpeedScale="1" foldMaxLimit="1" foldMinLimit="0" forcedState="boolean" iconType="CROSS" invertX="false" invertZ="false" node="node" scaleOffset="float" size="0.04" type="UNKNOWN"/>
                    
                    <!-- This control should not be functional all the time? Add a configuration restriction -->
                    <configurationsRestrictions>
                        <restriction indicies="1 2 .. n" name="string"/>
                    </configurationsRestrictions>
                    
                    <!-- Add a functio to your control, if you want to control a attached vehicle function, define an attacher joint index -->
                    <function name="string">
                        <attacherJoint index="integer"/>
                    </function>
                    
                    <objectChange centerOfMassActive="x y z" centerOfMassInactive="x y z" compoundChildActive="boolean" compoundChildInactive="boolean" interpolation="false" interpolationTime="1" massActive="float" massInactive="float" node="node" parentNodeActive="node" parentNodeInactive="node" rigidBodyTypeActive="string" rigidBodyTypeInactive="string" rotationActive="x y z" rotationInactive="x y z" scaleActive="x y z" scaleInactive="x y z" shaderParameter="string" shaderParameterActive="x y z w" shaderParameterInactive="x y z w" sharedShaderParameter="false" translationActive="x y z" translationInactive="x y z" visibilityActive="boolean" visibilityInactive="boolean"/>
                    <soundModifier indoorFactor="float"/>
                </interactiveControl>
                
                <!-- The outdoor trigger is important, if you want to use IC from the outside of a vehicle -->
                <outdoorTrigger node="node"/>
            </interactiveControls>
            
            <objectChange centerOfMassActive="x y z" centerOfMassInactive="x y z" compoundChildActive="boolean" compoundChildInactive="boolean" interpolation="false" interpolationTime="1" massActive="float" massInactive="float" node="node" parentNodeActive="node" parentNodeInactive="node" rigidBodyTypeActive="string" rigidBodyTypeInactive="string" rotationActive="x y z" rotationInactive="x y z" scaleActive="x y z" scaleInactive="x y z" shaderParameter="string" shaderParameterActive="x y z w" shaderParameterInactive="x y z w" sharedShaderParameter="false" translationActive="x y z" translationInactive="x y z" visibilityActive="boolean" visibilityInactive="boolean"/>
        </interactiveControlConfiguration>
    </interactiveControlConfigurations>
    
    <!-- if you want to use your own click icon, you easily can register it here -->
    <registers>
        <clickIcon blinkSpeed="float" filename="string" name="string" node="string"/>
    </registers>
</interactiveControl>

```
