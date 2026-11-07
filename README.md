# Euicc eSIM Restore

A KernelSU module that restores the stock Google eSIM Manager (`com.google.android.euicc`) on the OnePlus 13 GLO after updating to ColorOS 17.0.0.102.

## Root cause

The package is disabled in `/my_product/etc/config/app_v2.xml`:

```xml
<disable pkg="com.google.android.euicc" priority="7"/>
```

Because of this entry, Android does not register the built-in `/product/priv-app/EuiccGoogle/EuiccGoogle.apk` as a system app. As a result, the eSIM item disappears from Settings, and launching eSIM Manager directly fails with `WRITE_EMBEDDED_SUBSCRIPTIONS`.

## What the module does

During the `post-fs-data` stage, the module:

1. Reads the current `app_v2.xml` from the firmware.
2. Replaces `disable` with `enable` for `com.google.android.euicc` only.
3. Bind-mounts the patched copy over the original file using `mount --bind`.

Firmware files are not modified. All other configuration entries are preserved. If the erroneous `disable` entry is absent, the module does not mount anything.

## Requirements

- KernelSU with root access.
- The stock `EuiccGoogle.apk` at `/product/priv-app/EuiccGoogle`.
- Tested on the OnePlus 13 GLO running ColorOS 17.0.0.102 (`CPH2653`).

## Installation via KernelSU

1. Open **KernelSU → Modules**.
2. Select **Install from storage**.
3. Choose `euicc-esim-restore-v1.0.zip`.
4. Reboot the phone.

If the package was previously removed completely from the user data partition and does not register automatically after reboot, run once:

```sh
adb shell pm install-existing --full --user 0 com.google.android.euicc
```

## Verification

The eSIM item should appear under SIM cards and mobile network settings.

You can verify package registration via ADB:

```sh
adb shell pm path com.google.android.euicc
adb shell dumpsys package com.google.android.euicc
```

Expected path:

```text
/product/priv-app/EuiccGoogle/EuiccGoogle.apk
```

The package state should contain the `SYSTEM` flag.

## Uninstallation

Disable or remove the module in KernelSU and reboot the phone. The bind mount disappears, while the original firmware file remains untouched.

## Notes

- The module does not delete or modify profiles on the eUICC.
- The module does not replace the APK or grant permissions manually.
- After an OTA update, verify that eSIM still works: the contents of `app_v2.xml` and firmware behavior may change.
- No manual changes to regional settings, `ESIM_OPENING`, the EID, or telephony settings are required.
