rm -rf /gfb

groupadd -f DBD
groupadd -f DBB
groupadd -f dyrektor_DBD
groupadd -f dyrektor_DBB

mkdir -p /gfb
mkdir -p -m=777 /gfb/kredyty /gfb/lokaty /gfb/zadania
chown -R guest:guest /gfb
chmod -R 777 /gfb

SCRIPT_DIR="$(dirname $0)"

while read -r EMP_ID FIRST_NAME LAST_NAME FUNCTION DEPARTMENT; do
    USERNAME="$EMP_ID"_"$FIRST_NAME"_"$LAST_NAME"
    PASSWORD="$EMP_ID"
    DIRECTOR_GROUP="dyrektor_$DEPARTMENT"
    USER_FOLDER="/gfb/zadania/$EMP_ID"

    id -u "$USERNAME" > /dev/null 2>&1 || useradd "$USERNAME"
    echo "$PASSWORD\n$PASSWORD" | passwd "$USERNAME" > /dev/null 2>&1
    mkdir -p "$USER_FOLDER"
    setfacl -d -m g:"$DIRECTOR_GROUP":rwx "$USER_FOLDER"
    setfacl -m g:"$DIRECTOR_GROUP":rwx "$USER_FOLDER"
    chown :"$DEPARTMENT" "$USER_FOLDER"
    usermod -a -G "pracownik" "$USERNAME"
    usermod -a -G "$DEPARTMENT" "$USERNAME"
    if [ "$FUNCTION" = "dyrektor" ]; then
        usermod -a -G "$DIRECTOR_GROUP" "$USERNAME"
    fi

    mkhomedir_helper "$USERNAME" || true
    sudo -u "$USERNAME" "$SCRIPT_DIR/gen_ssh.sh"
done
