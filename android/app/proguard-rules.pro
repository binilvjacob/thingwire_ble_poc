# Keep all classes in the custom ESP library
-keep class how.virc.flutter_esp_ble_prov.** { *; }
-keep class com.espressif.** { *; }

# Keep EventBus related stuff
-keep class org.greenrobot.eventbus.** { *; }
-keepclassmembers class ** {
    @org.greenrobot.eventbus.Subscribe <methods>;
}

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep the specific classes from the logs that are failing
-keep class com.espressif.provisioning.DeviceConnectionEvent { *; }
-keep class com.espressif.provisioning.listeners.** { *; }

# Keep Bluetooth-related classes
-keep class android.bluetooth.** { *; }

# Keep the BLE provision manager
-keep class how.virc.flutter_esp_ble_prov.WifiProvisionManager { *; }
-keep class how.virc.flutter_esp_ble_prov.Boss { *; }