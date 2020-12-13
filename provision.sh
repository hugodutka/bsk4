rm -rf gfb

groupadd -f DBD
groupadd -f DBB
groupadd -f dyrektor_DBD
groupadd -f dyrektor_DBB

mkdir -p gfb
setfacl -d \
    -m g:DBD:r-x \
    -m g:DBB:r-x \
    -m g:dyrektor_DBD:r-x \
    -m g:dyrektor_DBB:r-x \
    gfb

mkdir -p -m=777 gfb/kredyty gfb/lokaty gfb/zadania
setfacl -d \
    -m user::rwx \
    -m user::rwx \
    gfb/kredyty gfb/lokaty

while read -r EMP_ID FIRST_NAME LAST_NAME FUNCTION DEPARTMENT; do
    USERNAME="$EMP_ID"_"$FIRST_NAME"_"$LAST_NAME"
    PASSWORD="$EMP_ID"
    DIRECTOR_GROUP="dyrektor_$DEPARTMENT"
    USER_FOLDER="gfb/zadania/$EMP_ID"

    id -u "$USERNAME" > /dev/null 2>&1 || useradd "$USERNAME"
    echo "$PASSWORD\n$PASSWORD" | passwd "$USERNAME" > /dev/null 2>&1
    mkdir -p "$USER_FOLDER"
    setfacl -d -m g:"$DIRECTOR_GROUP":rwx "$USER_FOLDER"
    setfacl -m g:"$DIRECTOR_GROUP":rwx "$USER_FOLDER"
    chown :"$DEPARTMENT" "$USER_FOLDER"
    usermod -a -G "$DEPARTMENT" "$USERNAME"
    if [ "$FUNCTION" = "dyrektor" ]; then
        usermod -a -G "$DIRECTOR_GROUP" "$USERNAME"
    fi
done
