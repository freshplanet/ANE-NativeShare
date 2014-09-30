Air Native Extension for Native Sharing (iOS)
======================================

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for displaying native share dialog on iOS and Android. It has been developed by [FreshPlanet](http://freshplanet.com).


Installation
---------

The ANE binary (AirNativeShare.ane) is located in the *bin* folder. You should add it to your application project's Build Path and make sure to package it with your app (more information [here](http://help.adobe.com/en_US/air/build/WS597e5dadb9cc1e0253f7d2fc1311b491071-8000.html)).


Usage
-----

This ANE currently supports displaying an alert popup with:
    
    ```actionscript
    // Defining your share object
    var myShareObject:AirNativeShareObject = new AirNativeShareObject();
    myShareObject.facebookText = "This will be shared on Facebook"
    myShareObject.facebookLink = "http://www.google.com"

    // Display a share dialog for the aforementioned shareObject
    AirNativeShare.getInstance().showShare(myShareObject)
    ```

Additionaly, on Android, you need to ask the following permission:
    
    ```
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    ```

Build script
---------

Should you need to edit the extension source code and/or recompile it, you will find an ant build script (build.xml) in the *build* folder:

    cd /path/to/the/ane/build
    mv example.build.config build.config
    #edit the build.config file to provide your machine-specific paths
    ant


Authors
------

This ANE has been written by [Thibaut Crenn](https://github.com/FreshTiti). It belongs to [FreshPlanet Inc.](http://freshplanet.com) and is distributed under the [Apache Licence, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).