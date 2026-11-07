#!/system/bin/sh

MODDIR=${0%/*}
CONFIG=/my_product/etc/config/app_v2.xml
PATCHED_CONFIG="$MODDIR/app_v2.xml"

[ -f "$CONFIG" ] || exit 0

sed 's|<disable pkg="com.google.android.euicc" priority="7"/>|<enable pkg="com.google.android.euicc" priority="7"/>|' \
    "$CONFIG" > "$PATCHED_CONFIG" || exit 0

# Do not mask the configuration if this firmware does not contain the bad entry.
if ! grep -q '<enable pkg="com.google.android.euicc" priority="7"/>' "$PATCHED_CONFIG"; then
    rm -f "$PATCHED_CONFIG"
    exit 0
fi

chmod 0644 "$PATCHED_CONFIG"
chcon u:object_r:system_file:s0 "$PATCHED_CONFIG" 2>/dev/null
mount --bind "$PATCHED_CONFIG" "$CONFIG"
