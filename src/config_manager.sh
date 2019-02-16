. $src_script_path/kwio.sh --source-only

# This function handling the save operation of '.config' file. It checks if the
# '.config' exists and saves it using git (dir.: kw/configs)
#
# @force Force option. If it is set and the current name was already saved,
#        this option will override the '.config' file under the 'name'
#        specified by '-n' without any message.
# @name This option specifies a name for a target .config file. This name
#       represents the access key for .config.
# @description Description for a config file, de descrition from '-d' flag.
function save_config_file()
{
  local ret=0
  local force=$1
  local name=$2
  local description=$3
  local current_path=$PWD
  local -r configs_path="$kw_config_files_path/configs"
  local -r metadata_dir="metadata"
  local -r configs_dir="configs"

  if [[ ! -f $current_path/.config ]]; then
    complain "There's no .config file in the current directory"
    exit 2 # ENOENT
  fi

  if [[ ! -d $configs_path ]]; then
    mkdir $configs_path
    cd $configs_path
    git init --quiet $configs_path
    mkdir $metadata_dir $configs_dir
  fi

  cd $configs_path

  # Check if the metadata related to .config file already exists
  if [[ ! -f $metadata_dir/$name ]]; then
    touch $metadata_dir/$name
  elif [[ $force != 1 ]]; then
    if [[ $(ask_yN "$name already exists. Update?") =~ "false" ]]; then
      complain "Save operation aborted"
      cd $current_path
      exit 0
    fi
  fi

  if [[ ! -z $description ]]; then
    echo $description > $configs_path/$metadata_dir/$name
  fi

  cp $current_path/.config $configs_path/$configs_dir/$name
  git add .
  git commit -m "New config file added: $USER - $(date)" > /dev/null 2>&1

  if [[ "$?" == 1 ]]; then
    warning "Warning: $name: there's nothing new in this file"
  else
    success "Saved $name"
  fi

  cd $current_path
}

function list_configs()
{
  local -r configs_path="$kw_config_files_path/configs"
  local -r metadata_dir="metadata"
  local -r configs_dir="configs"

  if [[ ! -d $configs_path ]]; then
    say "There's no tracked .config file"
    exit 0
  fi

  echo -e "Name\t\tDescription"
  echo -e "----\t\t------------"
  for filename in $configs_path/$metadata_dir/*; do
    local name=$(basename $filename)
    local content=$(cat $filename)
    echo -n $name
    echo -e "\t\t$content"
  done
}

# Support function for execute_config_manager()
function get_option_value()
{
  if [[ $1 = $2 ]]; then
    echo $3
  fi
}

# This function handles the options available in 'configm'.
#
# @* This parameter expects a list of parameters, such as '-n', '-d', and '-f'.
#
# Returns:
# Return 0 if everything ends well, otherwise return an errno code.
function execute_config_manager()
{
  local name_config
  local description_config
  local force=0

  [[ "${@// }" =~ "-f" ]] && force=1

  case $1 in
    --save)

      shift && name_config=$(get_option_value $1 "-n" $2)
      # Validate string name
      if [[ "$name_config" =~ ^- || -z "${name_config// }" ]]; then
        complain "Invalid argument"
        exit 22 # EINVAL
      fi
      # Shift 2 for skip '-n', 'parameter', and '-d'
      shift 2 && description_config=$@
      description_config=${description_config/-d}
      description_config=${description_config/-f}
      save_config_file $force $name_config "$description_config"
      ;;
    --ls)
      list_configs
      ;;
    *)
      complain "Unknown option"
      exit 22 #EINVAL
      ;;
  esac
}
