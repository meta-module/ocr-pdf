#!/bin/bash
# Locally installed software must be placed within /usr/local rather than /usr unless it is being installed to replace or upgrade software in /usr.
# https://github.com/mm/download

# CONTRIBUTION
## Author: Tom Sapletta
## Created Date: 06.02.2023
## Updated Date: XX.02.2023

## USAGE:
# ./mm.sh -h
# ./mm.sh --help
# mm --init
# mm example2.txt
# mm example/example3.txt
# mm --get "https://github.com/letpath/bash" "path"
# mm --get "https://github.com/botreck/puppeteer" "puppeter"
# mm --run
# mm --get "https://github.com/reactphp/dns" "reactphp"
# mm --get "https://github.com/letwhois/bash" "letwhois"
# mm --run "letwhois.ns("rezydent.de")"
# mm --run "http("https://www.rezydent.de/").xpath("title")"

## PARAMS
CMD=$1
OPTION=$CMD
(($# == 2)) && CMD=$2 && OPTION=$1
[ -z "$CMD" ] && CMD="-h"

#[ $# -ne 1 ] && echo "Exactly 1 param is needed" &&  exit 1

MODULE="mm"
VER="0.1.1"
FILE_EXT=".txt"
CMD_EXT=".sh"
CONFIG_FILE=".${MODULE}"
PACKAGE_FILE=".${MODULE}.txt"
ENV_FILE=".${MODULE}.env"
CONFIG_DEFAULT="${MODULE}${FILE_EXT}"
CONFIG_DEV="${MODULE}.dev${FILE_EXT}"
CONFIG_TEST="${MODULE}.test${FILE_EXT}"
INPUT_FOLDER=".${MODULE}"
COMMAND_LANGUAGE="bash"
CACHE_FOLDER=".${MODULE}.cache"
HISTORY_FOLDER=".${MODULE}.history"
FTIME="$(date +%s)"
INPUT_FILETIME="${CACHE_FOLDER}/${FTIME}"
CACHE_FILE="${INPUT_FILETIME}.cache${FILE_EXT}"
LOGS="${INPUT_FILETIME}.logs${FILE_EXT}"
CURRENT_FOLDER=$(pwd)
#
#FEDORA_INSTALL_PHP="dnf install php-cli"
FEDORA_INSTALL_PHP="dnf install php-cli php-json php-zip wget unzip -y"
#FEDORA_INSTALL_COMPOSER="php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');""
UBUNTU_INSTALL_PHP="apt install php-cli"
BUILD_PHP="composer update"
BUILD_NODEJS="npm update"
BUILD_PYTHON="python3 -m pip install -r requirements.txt"

# show last logs
if (($# == 1)); then

  # VERSION   ######################################
  if [ "$OPTION" == "-v" ] || [ "$OPTION" == "--version" ]; then
    echo "$MODULE v $VER"
    echo ":OS PACKAGES:"
    git --version
    curl --version | awk '{print $1 " v " $2}' | head -n 1
    echo ":GIT REPOS:"
    LIST=$(ls -d */)
    for git_folder in $LIST; do
      cd "${CURRENT_FOLDER}"
      echo "git remote -v ${git_folder}" >>$LOGS
      echo -n "./${git_folder} - "
      cd ${git_folder}
      git remote -v | grep fetch
    done
    exit
  fi

  # HELP INFO ######################################
  if [ "$OPTION" == "-h" ] || [ "$OPTION" == "--help" ]; then
    echo "$MODULE $VER"
    echo "OPERATOR or COMMAND is needed!"
    echo ""
    echo "# INTERNAL COMMANDS:"
    echo " -v, --version        show module version"
    echo " -e, --examples       download examples"
    echo " -g, --get            get without parameter show list of registry"
    echo " -g, --get <file>     get required dependency from a file"
    echo " -f, --fun            fun from command line"
    echo " -r, --run            run without params show the list of files inside"
    echo " -r, --run <file>     run mm script from a file"
    echo " --let <name> <value> let define the variables"
    echo " --put <one> <two> .. Put on the End Selected Values to lines"
    echo " --split <separator> .Put on the End Selected Values to lines"
    echo " --end                do summary on the end of script"
    echo ""
    echo "# OPERATORS:"
    echo " -c, --clean          clean cache data"
    echo " -h, --help           list of commands, examples,"
    echo " -h, --history        show logs during run"
    echo " -l, --logs           show logs during or after run"
    echo " -i, --init           copy command mm.sh to /usrl/local/bin to use mm such a system command in shell"
    echo " -i, --init <>        with 2 params: copy command mm to /usrl/local/bin to use mm such a system command in shell"
    echo " -u, --update         without params, update all repos in folder"
    echo " -d, --download       download from repository and save as mm file"
    echo ""
    echo " dev - development packages, for contributors and developers"
    echo " test - for testing the project"
    echo "# USAGE COMMAND:"
    echo "$MODULE 'get(\"https://github.com/letpath/bash\",\"path\")' - import project from git"
    echo "$MODULE 'path.load(\"flatedit.txt\")' - use imported command, such load file "
    exit
  fi

  ### UPDATE PROJECTS ######################################
  if [ "$OPTION" == "-u" ] || [ "$OPTION" == "--update" ]; then
    LIST=$(ls -d */)
    for git_folder in $LIST; do
      cd "${CURRENT_FOLDER}"
      echo "$git_folder"
      [ ! -d ${git_folder} ] && echo "!!! FOLDER ${git_folder} NOT EXIST" >>$LOGS && continue
      echo "git pull ${git_folder}" >>$LOGS
      cd ${git_folder}
      git pull
      chmod -R +x .
      [ "$(pwd)" == "$CURRENT_FOLDER" ] && echo "!!! GIT PROJECT ${git_repo} NOT EXIST, PLEASE INSTALL FIRST " >>$LOGS && continue
      [ -f ".gitignore" ] && echo "${git_folder}" >>.gitignore
      [ -f "composer.json" ] && ${BUILD_PHP}
      [ -f "package.json" ] && ${BUILD_NODEJS}
      [ -f "requirements.txt" ] && ${BUILD_PYTHON}
    done

    exit
  fi
fi

# PARSER CONFIG ######################################
#Create temporary file with new line in place
#cat $CMD | sed -e "s/)/\n/" > $CACHE_FILE
DSL_HASH="#"
DSL_SLASHSLASH='//'
DSL_SLASHSLASHSLASH='.///'
DSL_DOT="."
DSL_SEMICOLON=";"
DSL_LEFT_BRACE="("
DSL_RIGHT_BRACE=")"
DSL_RIGHT_BRACE_SEMICOLON=");"
DSL_RIGHT_BRACE_DOT=")."
DSL_NEW="\n"
DSL_EMPTY=""
DSL_LOOP="forEachLine"
SEARCH="."
REPLACE="_"
separator=","

# PREPARE NUMBER for LOGS
echo -n "$FTIME" >"$CONFIG_FILE"

# START
mkdir -p "$CACHE_FOLDER"
chmod +x $CACHE_FOLDER
echo "$(date +"%T.%3N") START" >$LOGS

echo "CMD $CMD" >>$LOGS
echo "OPTION $OPTION" >>$LOGS

# CONFIG FILE ######################################
if [ "$OPTION" == "init" ]; then
  echo -n "$CONFIG_DEFAULT" >"$CURRENT_FOLDER/$CONFIG_FILE"
  exit
fi
if [ "$OPTION" == "dev" ]; then
  echo -n "$CONFIG_DEV" >"$CURRENT_FOLDER/$CONFIG_FILE"
  exit
fi
if [ "$OPTION" == "test" ]; then
  echo -n "$CONFIG_TEST" >"$CURRENT_FOLDER/$CONFIG_FILE"
  exit
fi

if [ "$OPTION" == "-d" ] || [ "$OPTION" == "--download" ]; then
  FILE_TO_INSTALL=$2
  [ -z "$FILE_TO_INSTALL" ] && FILE_TO_INSTALL=mm.sh
  curl https://raw.githubusercontent.com/mm/download/main/mm.sh -o $FILE_TO_INSTALL
  exit
fi

if [ "$OPTION" == "-e" ] || [ "$OPTION" == "--examples" ]; then
  FILE_TO_INSTALL=$2
  [ -z "$FILE_TO_INSTALL" ] && FILE_TO_INSTALL=mm.sh
  git_folder=examples
  git clone https://github.com/mm/examples $git_folder
  [ -d ${git_folder} ] && cd ${git_folder} && git pull
  cp examples/*/*.mm ./
  exit
fi

if [ "$OPTION" == "-i" ] || [ "$OPTION" == "--init" ]; then
  FILE_TO_INSTALL=$2
  [ -z "$FILE_TO_INSTALL" ] && FILE_TO_INSTALL=mm.sh
  sudo cp -f $FILE_TO_INSTALL /usr/local/bin/mm
  exit
fi

if [ "$OPTION" == "-c" ] || [ "$OPTION" == "--clean" ]; then
  rm -rf "${CURRENT_FOLDER}/${CACHE_FOLDER}/"
  exit
fi

if [ "$OPTION" == "-h" ] || [ "$OPTION" == "--history" ]; then
  # get latest logs ID
  FTIME_LOGS=$(cat "$CONFIG_FILE")
  # Prepare Path based on latest logs ID
  INPUT_FILETIME_LOGS="${CACHE_FOLDER}/${FTIME_LOGS}"
  LOGS_FILE="${INPUT_FILETIME_LOGS}.logs${FILE_EXT}"
  CACHE_FILE="${INPUT_FILETIME_LOGS}.cache${FILE_EXT}"
  # Print script and logs
  echo -e "SCRIPTS:"
  cat $CACHE_FILE
  echo -e "\nLOGS:"
  cat $LOGS_FILE
  exit
fi

PROJECT_LIST=$2
[ -z "$PROJECT_LIST" ] && [ -f "$CONFIG_FILE" ] && PROJECT_LIST=$(cat "$CONFIG_FILE")
[ -z "$PROJECT_LIST" ] && PROJECT_LIST="$CONFIG_DEFAULT"
[ ! -f "$PROJECT_LIST" ] && echo -n "" >"$CONFIG_DEFAULT" && echo "$LOGS" >>".gitignore"
### CONFIG FILE ######################################
INPUT_FILE_PATH="${INPUT_FILETIME}${FILE_EXT}"
BASH_FILE="${INPUT_FILETIME}${CMD_EXT}"
END_FILE="${INPUT_FILETIME}.end${CMD_EXT}"
BASH_LOOP_FILE="${INPUT_FILETIME}.loop${CMD_EXT}"

# IMPORT COMMAND ##########################
#cd "${CURRENT_FOLDER}"
if [ "$OPTION" == "-g" ] || [ "$OPTION" == "--get" ]; then

  #echo $#

  # FROM COMMMAND
  if (($# == 3)); then
    #&& filename=$3 && CMD=$2 && OPTION=$1
    git_repo=$2
    git_repo="${git_repo%\"}"
    git_repo="${git_repo#\"}"

    git_folder=$3
    git_folder="${git_folder%\"}"
    git_folder="${git_folder#\"}"

    [ -d ${git_folder} ] && echo "!!! FOLDER ${git_folder} EXIST, PLEASE INSTALL IN ANOTHER FOLDER " >>$LOGS && exit
    #todo: replace git@github.com:
    echo "git clone ${git_repo} ${git_folder}" >>$LOGS
    git clone ${git_repo} ${git_folder} && cd ${git_folder} && chmod -R +x .
    [ "$(pwd)" == "$CURRENT_FOLDER" ] && echo "!!! GIT PROJECT ${git_repo} NOT EXIST, PLEASE INSTALL FIRST " >>$LOGS && exit
    [ -f ".gitignore" ] && echo "${git_folder}" >>.gitignore
    [ -f "composer.json" ] && ${BUILD_PHP}
    [ -f "package.json" ] && ${BUILD_NODEJS}
    [ -f "requirements.txt" ] && ${BUILD_PYTHON}
    exit
  fi

  # FROM custom FILE
  if (($# == 2)); then
    PACKAGE_FILE=(${2})
  fi

  #echo $PACKAGE_FILE

  [ ! -f ${PACKAGE_FILE} ] && echo "!!! FILE ${PACKAGE_FILE} NOT EXIST, PLEASE INSTALL IN ANOTHER FOLDER " >>$LOGS && exit

  while
    LINE=
    IFS=$' \t\r\n' read -r LINE || [[ $LINE ]]
  do
    [ -z "$LINE" ] && echo "REMOVED: $LINE" >>$LOGS && continue
    #echo "${line:0:1}"
    # Remove Comments
    [ "${LINE:0:1}" == "${DSL_HASH}" ] && continue
    [ "${LINE:0:1}" == "${DSL_SLASHSLASH}" ] && continue
    IFS=' ' read -a repo <<<"$LINE"
    git_repo=(${repo[0]})
    git_repo="${git_repo%\"}"
    git_repo="${git_repo#\"}"
    git_folder=(${repo[1]})
    git_folder="${git_folder%\"}"
    git_folder="${git_folder#\"}"
    [ -d ${git_folder} ] && echo "!!! FOLDER ${git_folder} EXIST, PLEASE INSTALL IN ANOTHER FOLDER " >>$LOGS && continue
    echo "2git clone ${git_repo} $git_folder" >>$LOGS
    git clone ${git_repo} ${git_folder} && cd ${git_folder} && chmod -R +x .
    [ "$(pwd)" == "$CURRENT_FOLDER" ] && echo "!!! GIT PROJECT ${git_repo} NOT EXIST IN ${git_folder}, PLEASE INSTALL FIRST " >>$LOGS && continue
    [ -f ".gitignore" ] && echo "${git_folder}" >>.gitignore
    [ -f "composer.json" ] && ${BUILD_PHP}
    [ -f "package.json" ] && ${BUILD_NODEJS}
    [ -f "requirements.txt" ] && ${BUILD_PYTHON}
  done <"$PACKAGE_FILE"
  exit
fi


# RUN COMMAND ##########################
#if [ "$OPTION" == "-f" ] || [ "$OPTION" == "--fun" ]; then
  #[ -z ${2} ] && ls -1 *.mm && exit
  #echo "${CMD}" >${INPUT_FILE_PATH}
#fi
#echo ${INPUT_FILE_PATH}
#exit

# RUN COMMAND ##########################
if [ "$OPTION" == "-r" ] || [ "$OPTION" == "--run" ]; then
  [ -z ${2} ] && ls -1 *.mm && exit
  filename=(${CMD})
  filename="${filename%\"}"
  filename="${filename#\"}"
  [ ! -f ${filename} ] && echo "!!! FILE/FOLDER ${filename} NOT EXIST, PLEASE INSTALL IN ANOTHER FOLDER " >>$LOGS && exit
  cp $filename ${INPUT_FILE_PATH}
else
  echo "${CMD}" >${INPUT_FILE_PATH}
fi

[ ! -f "$INPUT_FILE_PATH" ] && echo "$INPUT_FILE_PATH not exist" >>$LOGS && exit
echo "#!/bin/bash" >$BASH_FILE


echo "INPUT_FILE_PATH $INPUT_FILE_PATH" >>$LOGS
cat $INPUT_FILE_PATH >>$LOGS

# REMOVE COMMENTS ######################################
echo -n "" >$CACHE_FILE
while
  LINE=
  IFS=$' \t\r\n' read -r LINE || [[ $LINE ]]
do
  [ -z "$LINE" ] && echo "REMOVED: $LINE" >>$LOGS && continue
  #echo "${line:0:1}"
  # Remove Comments
  [ "${LINE:0:1}" == "${DSL_HASH}" ] && continue
  [ "${LINE:0:1}" == "${DSL_SLASHSLASH}" ] && continue
  echo "${LINE}" >>$CACHE_FILE
done <"$INPUT_FILE_PATH"

sed -i "s/${DSL_RIGHT_BRACE_DOT}/${DSL_NEW}/g" $CACHE_FILE
sed -i "s/${DSL_RIGHT_BRACE}/${DSL_NEW}/g" $CACHE_FILE
### REMOVE COMMENTS ######################################

# PREPARE functions ######################################
# array to hold all lines read
functions=()
values=()
#while IFS= read -r LINE; do
while
  LINE=
  IFS=$' \t\r\n' read -r LINE || [[ $LINE ]]
do
  #LINE=($line)
  echo "LINE BEFORE CLEANING: $LINE" >>$LOGS
  [ -z "$LINE" ] && continue
  ### SPLIT BY BRACE ##################################
  IFS="$DSL_LEFT_BRACE"
  read -ra line <<<"$LINE"
  #echo "LINE: $line"
  index=0
  key=""

  for i in "${line[@]}"; do
    index=$((index + 1))
    i="$(echo -e "${i}" | tr -d '[:space:]')"

    if [ $index -gt 2 ]; then
      echo $index "break"
    #  break
    fi

    if [ $index == 1 ]; then
      key=$i
    fi
  done
  echo " KEY: $key" >>$LOGS
  echo " VAL: $i" >>$LOGS

  ## depends param function exist or not
  [ "$key" = "$i" ] && functions+=("$key") && values+=("")
  [ "$key" != "$i" ] && functions+=("$key") && values+=("$i")

done <"$CACHE_FILE"
### PREPARE functions ######################################


#ENV
[ ! -f "$ENV_FILE" ] && echo -n "" >>$ENV_FILE
[ -f "$ENV_FILE" ] && cat "$ENV_FILE" >>$BASH_FILE


length=${#functions[@]}
loop=
loop_functions=()
loop_values=()
k=0
key=
value=
FIRST_SEPARATOR=
COMMAND_BEFORE=
for ((i = 0; i < ${length}; i++)); do
  echo " F$i: ${functions[$i]}" >>$LOGS
  echo " V$i: ${values[$i]}" >>$LOGS
  # Replace dot to slash for path at installed packages
  #key="${functions[$i]/./\/}"
  key="${functions[$i]}"
  value="${values[$i]}"

  # IMPORT COMMAND ##########################
  # install dependencies by apifork
  cd "${CURRENT_FOLDER}"
  if [ "$key" == "get" ]; then
    #[ ! -z "${keys[1]}" ] && CMD_FILE_NAME=${keys[1]} && CMD_FOLDER_NAME=/${keys[0]}
    IFS=',' read -a repo <<<"$value"
    git_repo=(${repo[0]})
    git_repo="${git_repo%\"}"
    git_repo="${git_repo#\"}"
    git_folder=(${repo[1]})
    git_folder="${git_folder%\"}"
    git_folder="${git_folder#\"}"
    [ -d ${git_folder} ] && echo "!!! FOLDER ${git_folder} EXIST, PLEASE INSTALL IN ANOTHER FOLDER " >>$LOGS && continue
    echo "git clone ${git_repo} ${git_folder}" >>$LOGS
    git clone ${git_repo} ${git_folder} && cd ${git_folder} && chmod -R +x .
    [ "$(pwd)" == "$CURRENT_FOLDER" ] && echo "!!! GIT PROJECT ${git_repo} NOT EXIST IN ${git_folder}, PLEASE INSTALL FIRST " >>$LOGS && continue
    [ -f ".gitignore" ] && echo "${git_folder}" >>.gitignore
    [ -f "composer.json" ] && ${BUILD_PHP}
    [ -f "package.json" ] && ${BUILD_NODEJS}
    [ -f "requirements.txt" ] && ${BUILD_PYTHON}
    continue
  fi
  ### IMPORT COMMAND ##########################

  # RUN COMMAND ##########################
  if [ "$key" == "run" ]; then
    filename=(${value})
    filename="${filename%\"}"
    filename="${filename#\"}"
    #echo $filename
    echo "RUN SELF mm --run ${filename} " >>$LOGS
    ## IN DEBUG MODE
    if [ -f "mm.sh" ]; then
      ./mm.sh --run ${value}
    else
      mm --run ${value}
    fi
    #[ ! -f "${filename}" ] && echo "!!! FILE/FOLDER ${filename} NOT EXIST, PLEASE INSTALL IN ANOTHER FOLDER " && continue
    exit
  fi
  ### RUN COMMAND ##########################

  # ARG COMMAND ##########################
  # install dependencies by apifork
  cd "${CURRENT_FOLDER}"
  if [ "$key" == "arg" ] || [ "$key" == "ARG" ]; then
    #[ ! -z "${keys[1]}" ] && CMD_FILE_NAME=${keys[1]} && CMD_FOLDER_NAME=/${keys[0]}
    IFS=',' read -a repo <<<"$value"
    let_name=(${repo[0]})
    let_name="${let_name/$/}"
    let_name="${let_name%\"}"
    let_name="${let_name#\"}"
    let_value=(${repo[1]})
    #echo $key
    #echo $let_value
    COMMAND_VALUE="read -p ${let_value} ${let_name}"
    #COMMAND_VALUE=${let_name}=${let_value}
    echo "$COMMAND_VALUE" >>$BASH_FILE
    #echo -n " | " >>$BASH_FILE
    echo "ADD CONSTANT $i: $COMMAND_VALUE TO FILE: $BASH_FILE" >>$LOGS
    continue
  fi
  ### arg COMMAND ##########################

  # LET COMMAND ##########################
  # install dependencies by apifork
  cd "${CURRENT_FOLDER}"
  if [ "$key" == "let" ] || [ "$key" == "LET" ]; then
    #[ ! -z "${keys[1]}" ] && CMD_FILE_NAME=${keys[1]} && CMD_FOLDER_NAME=/${keys[0]}
    IFS=',' read -a repo <<<"$value"
    let_name=(${repo[0]})
    let_name="${let_name/$/}"
    let_name="${let_name%\"}"
    let_name="${let_name#\"}"
    let_value=${repo[1]}
    #echo $key
    #echo $let_value
    COMMAND_VALUE=${let_name}=${let_value}
    echo "$COMMAND_VALUE" >>$BASH_FILE
    #echo -n " | " >>$BASH_FILE
    echo "ADD CONSTANT $i: $COMMAND_VALUE TO FILE: $BASH_FILE" >>$LOGS
    continue
  fi
  ### LET COMMAND ##########################

  # ENV COMMAND ##########################
  if [ "$key" == "env" ] || [ "$key" == "ENV" ]; then
    #[ ! -z "${keys[1]}" ] && CMD_FILE_NAME=${keys[1]} && CMD_FOLDER_NAME=/${keys[0]}
    IFS=',' read -a repo <<<"$value"
    let_name=(${repo[0]})
    let_name="${let_name/$/}"
    let_name="${let_name%\"}"
    let_name="${let_name#\"}"
    let_value=${repo[1]}
    let_value="${let_value%\"}"
    let_value="${let_value#\"}"
    #echo $key
    #echo $let_value
    COMMAND_VALUE="${let_name}=${let_value}"
    [ -f "$ENV_FILE" ] && echo "$COMMAND_VALUE" >>$ENV_FILE
    [ -f "$ENV_FILE" ] && echo "!!! ENV_FILE ($ENV_FILE) not exist" >>$LOGS && exit
    echo "ADD CONSTANT $i: $COMMAND_VALUE TO FILE: $BASH_FILE" >>$LOGS
    #ENV
    cat "$ENV_FILE" >>$BASH_FILE
    continue
  fi
  ### ENV COMMAND ##########################

  ### PUT COMMAND ##########################
  if [ "$key" == "put" ]; then
    #echo $value
    COMMAND_VALUE=""
    COMMAND_CURRENT=$key
    [ -z "$COMMAND_BEFORE" ] && COMMAND_BEFORE=$key

    ##SECOND=""
    #FIRSTY='echo "$(</dev/stdin)'
    echo -n "${COMMAND_CURRENT}=" >>$BASH_FILE
    echo -n '"' >>$BASH_FILE
    prefix=
    while IFS=, read -ra items; do
      for item in "${items[@]}"; do
        #echo $item
        #COMMAND_VALUE+="$FIRSTY ${item}"
        #echo -n ${item} >>$BASH_FILE
        item="${item%\"}"
        item="${item#\"}"
        item=${item/$SEARCH/$REPLACE}
        echo -n ${prefix}${item} >>$BASH_FILE
        prefix=${separator}
      done
    done <<<"$value"
    echo '"' >>$BASH_FILE
    #echo -n ${COMMAND_VALUE} >>$BASH_FILE

    #echo -n " | " >>$BASH_FILE
    #echo "$COMMAND_VALUE"
    echo "ADD VARIABLE $i: $COMMAND_VALUE TO FILE: $BASH_FILE" >>$LOGS
    continue
  fi
  ### PUT COMMAND ##########################

  ### PRINT COMMAND ##########################
  if [ "$key" == "print" ]; then
    #echo $value
    COMMAND_VALUE=""
    COMMAND_CURRENT="echo \$${COMMAND_BEFORE}"
    echo ${COMMAND_CURRENT} >>$BASH_FILE

    echo "ADD VARIABLE $i: $COMMAND_VALUE TO FILE: $BASH_FILE" >>$LOGS
    continue
  fi
  ### PRINT COMMAND ##########################

  #OPEN ON THE END

  ### OPEN FILE COMMAND ##########################
  if [ "$key" == "open" ]; then
    COMMANDO="xdg-open ${value}"
    echo ${COMMANDO} >>$END_FILE
    echo "ADD VARIABLE $i: $COMMAND_VALUE TO FILE: $END_FILE" >>$LOGS
    continue
  fi
  ### OPEN FILE COMMAND ##########################
  ### WEBSITE COMMAND ##########################
  if [ "$key" == "browser" ]; then
    COMMANDO="x-www-browser ${value}"
    echo ${COMMANDO} >>$END_FILE
    echo "ADD VARIABLE $i: $COMMAND_VALUE TO FILE: $END_FILE" >>$LOGS
    continue
  fi
  ### WEBSITE COMMAND ##########################
  ### WEBSITE COMMAND ##########################
  if [ "$key" == "firefox" ]; then
    COMMANDO="firefox ${value}"
    echo ${COMMANDO} >>$END_FILE
    echo "ADD VARIABLE $i: $COMMAND_VALUE TO FILE: $END_FILE" >>$LOGS
    continue
  fi
  ### WEBSITE COMMAND ##########################
  ### WEBSITE COMMAND ##########################
  if [ "$key" == "chrome" ]; then
    COMMANDO="sensible-browser ${value}"
    echo ${COMMANDO} >>$END_FILE
    echo "ADD VARIABLE $i: $COMMAND_VALUE TO FILE: $END_FILE" >>$LOGS
    continue
  fi
  ### WEBSITE COMMAND ##########################

  #k=$((k+1))
  IFS='.' read -a keys <<<"$key"
  #value="${values[$i]}"
  CMD_FILE_NAME=$key
  CMD_FOLDER_NAME=
  echo "ADD COMMAND $i: $key $value" >>$LOGS

  [ ! -z "${keys[1]}" ] && CMD_FILE_NAME=${keys[1]} && CMD_FOLDER_NAME=/${keys[0]}
  [ "$key" == "split" ] && loop="1"


  #[ "$key" == "filesRecursive" ] && loop="1"
  if [ -z "$loop" ]; then
    COMMAND_CURRENT=$key
    #COMMAND_VALUE="$COMMAND_CURRENT=$($prefix .${CMD_FOLDER_NAME}/${CMD_FILE_NAME}.sh ${value})"
    #[ ! -z "$FIRST_SEPARATOR" ] && echo -n " | " >>$BASH_FILE
    #FIRST_SEPARATOR=1
    #echo "$COMMAND_VALUE" >>$BASH_FILE
    COMMAND_CURRENT=${COMMAND_CURRENT/$SEARCH/$REPLACE}
    echo -n "${COMMAND_CURRENT}=" >>$BASH_FILE
    echo -n '$(' >>$BASH_FILE
    [ ! -z "$COMMAND_BEFORE" ] && echo -n " echo \$${COMMAND_BEFORE} | " >>$BASH_FILE
    echo " .${CMD_FOLDER_NAME}/${CMD_FILE_NAME}.sh ${value})" >>$BASH_FILE
    COMMAND_BEFORE=${COMMAND_CURRENT}
    #echo -n " | " >>$BASH_FILE
    #    echo -n " && cd $CURRENT_FOLDER " >>$BASH_FILE
    echo "ADD COMMAND $i: $COMMAND_CURRENT TO FILE: $BASH_FILE" >>$LOGS
  else
    loop_functions+=("$key")
    loop_values+=("$value")
    echo "ADD KEY: $key TO ARRAY LOOP" >>$LOGS
  fi
done


## LOOP ##########################
## LOOP with split function
## TODO: more loop options
## TODO: many loop in one sentence
if [ ! -z "$loop" ]; then
  #echo $BASH_LOOP_FILE
  #echo -n "./$BASH_LOOP_FILE " >>$BASH_FILE

  length=${#loop_functions[@]}
  first=1
  show_echo=
  for ((i = 0; i < ${length}; i++)); do
    #echo "${loop_functions[$i]}"
    #echo "${loop_values[$i]}"
    key="${loop_functions[$i]}"
    IFS='.' read -a keys <<<"$key"
    value="${loop_values[$i]}"
    CMD_FILE_NAME=$key
    CMD_FOLDER_NAME=
    [ ! -z "${keys[1]}" ] && CMD_FILE_NAME=${keys[1]} && CMD_FOLDER_NAME=/${keys[0]}

    if [ ! -z "$first" ]; then
      echo "for ITEM in \$${COMMAND_CURRENT}; do" >$BASH_LOOP_FILE
      #echo -n ".${CMD_FOLDER_NAME}/${CMD_FILE_NAME}.sh $value" >>$BASH_LOOP_FILE
      #echo -n ' | ' >>$BASH_LOOP_FILE
    else
      ## REPLACE dot to underscore
      value=${value/$SEARCH/$REPLACE}
      ## FIND VARIABLE, if is equal to before, replace as ITEM
      findd="\$$COMMAND_BEFORE"
      replacee="\$ITEM"
      value=${value/$findd/$replacee}

      #[[ $value != *"$replacee"* ]] && [ -z "$first" ] && echo -n 'echo "$ITEM" | ' >>$BASH_LOOP_FILE
      [[ $value != *"$replacee"* ]] && [ -z "$show_echo" ] && echo -n 'echo "$ITEM" | ' >>$BASH_LOOP_FILE

      # IF value is empty then not add an echo
      if [ ! -z "$value" ]; then
        show_echo=1
      fi

      echo -n ".${CMD_FOLDER_NAME}/${CMD_FILE_NAME}.sh $value" >>$BASH_LOOP_FILE
      echo -n ' | ' >>$BASH_LOOP_FILE
      #echo -n "./$COMMAND_FOLDER/$key.sh $value" >>$BASH_LOOP_FILE
      #echo -n " | " >>$BASH_LOOP_FILE
    fi
    #echo ' ' >>$BASH_LOOP_FILE
    first=
  done
  truncate -s -3 $BASH_LOOP_FILE

  echo "" >>$BASH_LOOP_FILE
  echo "done" >>$BASH_LOOP_FILE
  #echo 'done <<< "$list"' >>$BASH_LOOP_FILE
  #else
  ##echo $key
  #[ "$key" != "put" ] &&
  #truncate -s -3 $BASH_FILE
  cat $BASH_LOOP_FILE >>$BASH_FILE
fi
## LOOP ##########################

#echo "RUN: $BASH_FILE" >> $LOGS
[ -r $END_FILE ] && cat $END_FILE >> $BASH_FILE

chmod +x $BASH_FILE
./$BASH_FILE
echo "END: $BASH_FILE" >>$LOGS

if [ "$OPTION" == "-l" ] || [ "$OPTION" == "--logs" ]; then
  echo -e "\n\nCOMMANDS:"
  cat $CACHE_FILE
  echo -e "\n\nSCRIPTS:"
  cat $BASH_FILE
  echo -e "\n\nLOGS:"
  cat $LOGS
fi
