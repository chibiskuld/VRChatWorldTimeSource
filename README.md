# VRChat World Time Source Package
This package contains prefabs that allows you to add a time source to your VRChat world, as well as a means of accessing that time source from your avatars custom shaders. The time source prefab is first placed into your world. Then it allows for you to access the current time through a shader on your avatar, if you within a world with the timesource prefab. If a time source is not available, the time you have been in the world will be supplied instead. There are two variants of the packages. One for SDK2, and one for SDK3. The SDK2 package retrieves time from this:  
https://www.studiojaw.com/time/  
While the SDK3 package retrieves the time from your local system time, utilizing UdonSharp.

## what all is in the package?
This package contains Three elements:
  - A prefab for either SDK2 or SDK3 that supplies avatars time from your world.
  - A .cginc that supplies the method GetTime() that will allow you to access the time source from your shader.
  - An example clock you can use, alter, etc.

## Requirements
### SDK2
VRChat SDK2.  
### SDK3
VRChat SDK3, Udon, & [UdonSharp](https://github.com/Merlin-san/UdonSharp)

## How to Use
### Downlod the package for the appropriate SDK
SDK2:
https://github.com/chibiskuld/VRChatWorldTimeSource/releases/download/0.9/VRChatWorldTimeSourceSDK2.unitypackage
SDK3: 
https://github.com/chibiskuld/VRChatWorldTimeSource/releases/download/0.9/VRChatWorldTimeSourceSDK3.unitypackage

### Setup your world
In the folder `/Assets/VRChatWorldTimeSource/Prefabs` you will find the TimeSource prefab to add to your world. Drag this into your Hierchy, and tuck it away in your scene some place it won't be seen. (It is masked by layer, but you never know)

### Using the .cginc
In the folder `/Assets/VRChatWorldTimeSource/Shaders` is the file `VRChatTimeSource.cginc`, you should copy this to the folder with your shader. To include just simply:  
```
#include "VRChatTimeSource.cginc"
```  
The time is then supplied to your avatar in a float3, you can get the time like this:  
```
float3 time = GetTime()
```
The structure of time looks like this:  
```
//The time bits are supplied as float for animation effects.
time.x //The current Hour supplied as 0-24  
time.y //The current Minute supplied as 0-60  
time.z //The current Second supplied as 0-60
```

### I need an example
Supplied in the folder `/Assets/VRChatWorldTimeSource/Prefabs` is `clock` Drag and drop that into the scene, and feel free to tear that apart to figure out what I've done. Usage of `VRChatTimeSource.cginc` can be found in the shader `/Assets/VRChatWorldTimeSource/Shaders/Toon/Toon.clock.cginc`.

## Credits
I pieced together all of this, but the idea comes from [Merlin](https://github.com/Merlin-san). The bridge that connects all of this is made possible by a trick discovered by [Scruffy](https://github.com/ScruffyRules/_VRChat_VideoPlayer)
