#!/bin/bash

BLUE='\e[34m'
PURPLE='\e[35m'
NC='\e[0m'


LOCAL_SYSTEM="local"
REMOTE_SYSTEM="dev"

CURRENT_PATH=$(dirname "$0")
CURRENT_PATH=$(cd "$CURRENT_PATH" && pwd)
if [[ $CURRENT_PATH == *"development"* ]]; then
  REMOTE_SYSTEM="test"
fi
if [[ $CURRENT_PATH == *"testing"* ]]; then
  REMOTE_SYSTEM="prod"
fi


CONFIRM=1
BACKUP=0
DB=1
MEDIA=1
PLUGINS=1
CACHE=1
RSYNC_OPTIONS=(--info=progress2)
ANONYMIZE=0


SET_VAL=""
while [ -n "$1" ]; do
	case "$1" in
	-f   | --force)           CONFIRM=0 ;;
  -b   | --backup)          BACKUP=1 ;;
  -ndb | --np-datebase)     DB=0 ;;
  -nm  | --no-media)        MEDIA=0 ;;
  -np  | --no-plugins)      PLUGINS=0 ;;
  -nc  | --no-clear-cache)  CACHE=0 ;;
  -a   | --anonymize)       ANONYMIZE=1 ;;
  --rsync-stats)            RSYNC_OPTIONS=("${RSYNC_OPTIONS[@]}" --stats) ;;
  --rsync-silent)           RSYNC_OPTIONS=() ;;
  --to)                     SET_VAL="LOCAL_SYSTEM";;
  --from)                   SET_VAL="REMOTE_SYSTEM";;
  -h   | --help)
    echo -e "Usage copyDbAndMedia.sh [OPTION]\n"
    echo -e "Options:"
    echo -e "-h,   --help               Show this help"
    echo -e "-f,   --force              Execute without asking the user to confirm"
    echo -e "-b,   --backup             Create Backup of DB and files"
    echo -e "-ndb, --np-database        Do not copy DB"
    echo -e "-nm,  --no-media           Do not copy media files"
    echo -e "-np,  --no-plugins         Do not copy plugins"
    echo -e "-nc,  --no-clear-cache     Do not clear cache and reinstall plugins and theme"
    echo -e "-a,   --anonymize          Anonymize customer dater"
    echo -e "      --rsync-stats        Show the rsync stats after copying files"
    echo -e "      --rsync-silent       Run rsync without progress: --info=progress2"
    echo -e "      --to [VALUE]         Default='local'. Set the name of the target system. [VALUE].env file has to exist."
    echo -e "      --from [VALUE]       Default='dev'. Set the name of the system to replicate. [VALUE].env file has to exist."
    echo
    exit
  ;;

	*)
	  if [[ $SET_VAL == "" ]]; then
      echo -e "Option $1 not recognized\nUse argument -h to get a list of all valid arguments"
      exit
	  else
	    declare $SET_VAL="$1"
	    SET_VAL=""
	  fi
	;;
	esac
	shift
done

RSYNC_OPTIONS=("${RSYNC_OPTIONS[@]}" --delete)





#
# Function to load settings from an environment file
# https://gist.github.com/mihow/9c7f559807069a03e302605691f85572?permalink_comment_id=3799505#gistcomment-3799505
#
loadEnv() {
  local envFile="${1?Missing environment file}"
  local environmentAsArray variableDeclaration
  mapfile environmentAsArray < <(
    grep --invert-match '^#' "${envFile}" | grep --invert-match '^\s*$'
  ) # Uses grep to remove commented and blank lines
  for variableDeclaration in "${environmentAsArray[@]}"; do
    export "${2}${variableDeclaration//[$'\r\n']}" # The substitution removes the line breaks
  done
}



#
# Settings for the Target-System. Default: Dockware
#
if [ -f "${CURRENT_PATH}/${LOCAL_SYSTEM}.env" ]; then
  loadEnv "${CURRENT_PATH}/${LOCAL_SYSTEM}.env" LOCAL_
else
  echo "File '${CURRENT_PATH}/${LOCAL_SYSTEM}.env' not found. Provide the settings for the target system."
  exit
fi
# Create sql settings array
LOCAL_SQL_SETTINGS=()
if [ -n "${LOCAL_DB_HOST}" ]; then
  LOCAL_SQL_SETTINGS=("${LOCAL_SQL_SETTINGS[@]}" -h "${LOCAL_DB_HOST}")
fi
if [ -n "${LOCAL_DB_USER}" ]; then
  LOCAL_SQL_SETTINGS=("${LOCAL_SQL_SETTINGS[@]}" -u "${LOCAL_DB_USER}")
fi
if [ -n "${LOCAL_DB_PASS}" ]; then
  LOCAL_SQL_SETTINGS=("${LOCAL_SQL_SETTINGS[@]}" "-p${LOCAL_DB_PASS}")
fi
if [ -n "${LOCAL_DB_NAME}" ]; then
  LOCAL_SQL_SETTINGS=("${LOCAL_SQL_SETTINGS[@]}" "${LOCAL_DB_NAME}")
fi
if [ -n "${LOCAL_DB_PORT}" ]; then
  LOCAL_SQL_SETTINGS=("${LOCAL_SQL_SETTINGS[@]}" --port "${LOCAL_DB_PORT}")
fi


#
# Settings for the Source/Remote - System
#
if [ -f "${CURRENT_PATH}/${REMOTE_SYSTEM}.env" ]; then
  loadEnv "${CURRENT_PATH}/${REMOTE_SYSTEM}.env" REMOTE_
else
  echo "File '${CURRENT_PATH}/${REMOTE_SYSTEM}.env' not found. Provide the settings for the remote system."
  exit
fi
# Create sql settings string
REMOTE_SQL_SETTINGS=""
if [ -n "${REMOTE_DB_HOST}" ]; then
  REMOTE_SQL_SETTINGS="${REMOTE_SQL_SETTINGS} -h ${REMOTE_DB_HOST}"
fi
if [ -n "${REMOTE_DB_USER}" ]; then
  REMOTE_SQL_SETTINGS="${REMOTE_SQL_SETTINGS} -u ${REMOTE_DB_USER}"
fi
if [ -n "${REMOTE_DB_PASS}" ]; then
  REMOTE_SQL_SETTINGS="${REMOTE_SQL_SETTINGS} -p${REMOTE_DB_PASS}"
fi
if [ -n "${REMOTE_DB_NAME}" ]; then
  REMOTE_SQL_SETTINGS="${REMOTE_SQL_SETTINGS} ${REMOTE_DB_NAME}"
fi
if [ -n "${REMOTE_DB_PORT}" ]; then
  REMOTE_SQL_SETTINGS="${REMOTE_SQL_SETTINGS} --port ${REMOTE_DB_PORT}"
fi




#
# Prepare "ignore-table" statement
#
DUMP_PARA="";
REMOTE_IGNORE_TABLES="frosh_mail_archive;log_entry;version_commit_data;cart"

if [ -n "$REMOTE_IGNORE_TABLES" ]; then
  export IFS=";"
  for IGNORE_TABLE in $REMOTE_IGNORE_TABLES; do
    DUMP_PARA="${DUMP_PARA}--ignore-table=${REMOTE_DB_NAME}.${IGNORE_TABLE} "
  done
fi





echo -e "\n${PURPLE}Copy from ${BLUE}${REMOTE_SYSTEM}${NC} to ${BLUE}${LOCAL_SYSTEM}${NC}"
echo -e " - Backup:                 $BACKUP"
echo -e " - Copy DB:                $DB"
echo -e " - Copy Files and Images:  $MEDIA"
echo -e " - Copy Plugins:           $PLUGINS"
echo -e " - Build and clear cache:  $CACHE"
if [[ "$CONFIRM" -eq 1 ]] ; then
  while true; do
      read -r -p "Are you sure? " yn
      case $yn in
          [Yy]* ) break ;;
          [Nn]* ) printf "\n\n" && exit;;
          * ) echo "Please answer yes or no.";;
      esac
  done
fi
echo



DATETIME="$(date +%Y-%m-%d_%H:%M)"



if [[ "$BACKUP" -eq 1 ]] ; then
  echo -e "\n${PURPLE}Create local backup in ${BLUE}${LOCAL_SW_ROOT}/files/backup/${DATETIME}${NC}"
  mkdir -p "${LOCAL_SW_ROOT}/files/backup/${DATETIME}"
  mysqldump "${LOCAL_SQL_SETTINGS[@]}" > "${LOCAL_SW_ROOT}/files/backup/${DATETIME}/backup.sql"

  mkdir -p "${LOCAL_SW_ROOT}/files/backup/${DATETIME}/files"
  cp -r "${LOCAL_SW_ROOT}/files/files/media" "${LOCAL_SW_ROOT}/files/backup/${DATETIME}/files"

  mkdir -p "${LOCAL_SW_ROOT}/files/backup/${DATETIME}/public"
  cp -r "${LOCAL_SW_ROOT}/files/public/media" "${LOCAL_SW_ROOT}/files/backup/${DATETIME}/public"
  cp -r "${LOCAL_SW_ROOT}/files/public/thumbnail" "${LOCAL_SW_ROOT}/files/backup/${DATETIME}/public"
fi


if [[ "$DB" -eq 1 ]] ; then
  echo -e "\n${PURPLE}Loading remote database${NC}"
  POSTFIX="${DATETIME}.${REMOTE_SYSTEM}"
  FILE_SCHEMA="copyDb_schema_${POSTFIX}.sql"
  FILE_DATA="copyDb_${POSTFIX}.sql"
  FILE_DATA_GZ="${FILE_DATA}.gz"

  echo -e " - Create remote DB Schema"
  # shellcheck disable=SC2029
  ssh "$REMOTE_HOST" "mysqldump${REMOTE_SQL_SETTINGS} --no-tablespaces --no-data --single-transaction > ${REMOTE_SW_ROOT}/${FILE_SCHEMA}"
  echo -e " - Load remote DB Schema"
  rsync --remove-source-files -a "${REMOTE_HOST}:${REMOTE_SW_ROOT}/${FILE_SCHEMA}" "${CURRENT_PATH}/${FILE_SCHEMA}"
  echo -e " - Replace Database-Name, Remove DEFINER-Command and Change Charset"
  sed -i "s|$REMOTE_DB_NAME|$LOCAL_DB_NAME|g" "${CURRENT_PATH}/${FILE_SCHEMA}"
  sed -i 's/DEFINER=[^*]*\*/\*/g' "${CURRENT_PATH}/${FILE_SCHEMA}"
  sed -i \
    -e 's/\<=utf8\>/=utf8mb4/' \
    -e 's/\<utf8_unicode_ci\>/utf8mb4_unicode_ci/' \
    -e 's/\<utf8_general_ci\>/utf8mb4_unicode_ci/' \
    -e 's/\<utf8mb4_0900_ai_ci\>/utf8mb4_unicode_ci/' \
    -e 's/\<utf8\>/utf8mb4/' \
    -e 's/\<CHARSET=utf8\>/CHARSET=utf8mb4/' \
    -e 's/\<COLLATE=utf8_unicode_ci\>/COLLATE=utf8mb4_unicode_ci/' \
    -e 's/\<COLLATE utf8_unicode_ci\>/COLLATE utf8mb4_unicode_ci/' \
    -e 's/\<COLLATE=utf8mb4_0900_ai_ci\>/COLLATE=utf8mb4_unicode_ci/' \
    -e 's/\<COLLATE utf8mb4_0900_ai_ci\>/COLLATE utf8mb4_unicode_ci/' \
    -e 's/\<utf8mb4mb4\>/utf8mb4/' "${CURRENT_PATH}/${FILE_SCHEMA}"
  echo -e " - Create remote DB data-dump"
  # shellcheck disable=SC2029
  ssh "$REMOTE_HOST" "mysqldump${REMOTE_SQL_SETTINGS} --no-tablespaces --single-transaction --quick $REMOTE_DUMP_PARA | gzip > ${REMOTE_SW_ROOT}/${FILE_DATA_GZ}"
  echo -e " - Load remote DB data-dump"
  rsync --remove-source-files -a "${REMOTE_HOST}:${REMOTE_SW_ROOT}/${FILE_DATA_GZ}" "${CURRENT_PATH}/${FILE_DATA_GZ}"
  echo -e " - Unzip DB data-dump"
  gunzip -f "${CURRENT_PATH}/${FILE_DATA_GZ}"
  echo -e " - Replace Database-Name, Remove DEFINER-Command and Change Charset"
  sed -i \
      -e 's/DEFINER=[^*]*\*/\*/g' \
      -e 's/\<=utf8\>/=utf8mb4/' \
      -e 's/\<utf8_unicode_ci\>/utf8mb4_unicode_ci/' \
      -e 's/\<utf8_general_ci\>/utf8mb4_unicode_ci/' \
      -e 's/\<utf8mb4_0900_ai_ci\>/utf8mb4_unicode_ci/' \
      -e 's/\<utf8\>/utf8mb4/' \
      -e 's/\<CHARSET=utf8\>/CHARSET=utf8mb4/' \
      -e 's/\<COLLATE=utf8_unicode_ci\>/COLLATE=utf8mb4_unicode_ci/' \
      -e 's/\<COLLATE utf8_unicode_ci\>/COLLATE utf8mb4_unicode_ci/' \
      -e 's/\<COLLATE=utf8mb4_0900_ai_ci\>/COLLATE=utf8mb4_unicode_ci/' \
      -e 's/\<COLLATE utf8mb4_0900_ai_ci\>/COLLATE utf8mb4_unicode_ci/' \
      -e 's/\<utf8mb4mb4\>/utf8mb4/' \
      -e 's/GENERATED ALWAYS AS.*[VIRTUAL|STORED],$/NULL DEFAULT NULL,/g' \
      "${CURRENT_PATH}/${FILE_DATA}"
#      -e "s|${REMOTE_DB_NAME}|${LOCAL_DB_NAME}|g" \
#
# CAUTION!!!
# 's/GENERATED ALWAYS AS.*[VIRTUAL|STORED],$/NULL DEFAULT NULL,/g'
# This replaces all generated columns with nullable columns.
# Otherwise import of MariaDB-Dump does not work.
# Use a script in 'modify_after.sql' regenerate the generated columns.
#


  echo -e "\n${PURPLE}Overwrite local database${NC}"
  echo -e " - Disable FOREIGN_KEY_CHECKS"
  mysql "${LOCAL_SQL_SETTINGS[@]}" -e "SET FOREIGN_KEY_CHECKS = 0;"
  if [ -f "${CURRENT_PATH}/modify_before.sql" ]; then
    echo -e " - Modify before Copy DB"
    mysql "${LOCAL_SQL_SETTINGS[@]}" < "${CURRENT_PATH}/modify_before.sql"
  fi
  echo -e " - Overwrite local DB-Schema with remote DB-Schema"
  mysql "${LOCAL_SQL_SETTINGS[@]}" < "${CURRENT_PATH}/${FILE_SCHEMA}"
  echo -e " - Overwrite local DB with remote DB"
  mysql "${LOCAL_SQL_SETTINGS[@]}" < "${CURRENT_PATH}/${FILE_DATA}"
  if [ -f "${CURRENT_PATH}/modify_after.sql" ]; then
    echo -e " - Modify after Copy DB"
    mysql "${LOCAL_SQL_SETTINGS[@]}" < "${CURRENT_PATH}/modify_after.sql"
  fi
  echo -e " - Enable FOREIGN_KEY_CHECKS"
  mysql "${LOCAL_SQL_SETTINGS[@]}" -e "SET FOREIGN_KEY_CHECKS = 1;"
  echo -e " - Overwrite with local changes"
  mysql "${LOCAL_SQL_SETTINGS[@]}" < "${CURRENT_PATH}/settings.${LOCAL_SYSTEM}.sql"

  if [ "${ANONYMIZE}" -eq 1 ] ; then
    echo -e " - Anonymize DB"
    mysql "${LOCAL_SQL_SETTINGS[@]}" < "${CURRENT_PATH}/anonymize.sql"
  fi

  rm -f "${CURRENT_PATH}/${FILE_DATA_GZ}"
  rm -f "${CURRENT_PATH}/${FILE_DATA}"
  rm -f "${CURRENT_PATH}/${FILE_SCHEMA}"
fi


if [[ "$PLUGINS" -eq 1 ]] ; then
  echo -e "\n${PURPLE}Loading remote Plugins${NC}"
  mkdir -p "${LOCAL_SW_ROOT}/custom/plugins"
  rsync -a "$REMOTE_HOST:$REMOTE_SW_ROOT/custom/plugins" "${LOCAL_SW_ROOT}/custom" "${RSYNC_OPTIONS[@]}"

  echo -e "\n${PURPLE}Loading remote build Plugin-Bundles (JS / CSS)${NC}"
  mkdir -p "${LOCAL_SW_ROOT}/public/bundles"
  rsync -a "$REMOTE_HOST:$REMOTE_SW_ROOT/public/bundles" "${LOCAL_SW_ROOT}/public" "${RSYNC_OPTIONS[@]}"
fi



if [[ "$CACHE" -eq 1 ]] ; then
  echo -e "\n${PURPLE}RE-BUILD, Clear cache...${NC}"
  cd "${LOCAL_SW_ROOT}"/.. && make xdebug-off

  cd "${LOCAL_SW_ROOT}" || exit

  "${LOCAL_SW_ROOT}"/bin/console cache:clear
fi



if [[ "$MEDIA" -eq 1 ]] ; then
  echo -e "\n${PURPLE}Loading remote public/media files${NC}"
  mkdir -p "${LOCAL_SW_ROOT}/public/media"
  rsync -a "$REMOTE_HOST:$REMOTE_SW_ROOT/public/media" "${LOCAL_SW_ROOT}/public" "${RSYNC_OPTIONS[@]}"

  echo -e "\n${PURPLE}Loading remote public/thumbnail${NC}"
  mkdir -p "${LOCAL_SW_ROOT}/public/thumbnail"
  rsync -a "$REMOTE_HOST:$REMOTE_SW_ROOT/public/thumbnail" "${LOCAL_SW_ROOT}/public" "${RSYNC_OPTIONS[@]}"
fi


echo
