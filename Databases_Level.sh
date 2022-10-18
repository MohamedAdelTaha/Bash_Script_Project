#! /bin/bash
export PS3=">"
function is_db_exists () {
    new_db_name=$1
    all_databases=$(ls -F ~/Desktop/Bash_Project/Databases/ | grep /)
    found_flag="false"
    for db in ${all_databases}; do
        if [[ "${db}" == "${new_db_name}" ]]; then
            found_flag="true"
            break
        fi
    done
    
    echo $found_flag
}

function create_db_scenario () {
    
    read -r -p "Enter the database name: " db_name
    name_val=$(name_validity.sh "${db_name}")
    if [[ "${name_val}" == "success" ]]; then
        if [[ "$(is_db_exists "${db_name}")" == "false" ]]; then
            cd ~/Desktop/Bash_Project/Databases/
            mkdir "${db_name}"
            echo "Database created successfully"
        else
            echo "cannot create Database ${db_name}: Database exists"
        fi
            
    else 
        echo "An error occurred (details --> ${name_val})"
    fi
}

function drop_db_scenario () {
    read -r -p "Enter the database name: " db_name
    if [[ "$(is_db_exists "${db_name}/")" == "true" ]]; then
        cd ~/Desktop/Bash_Project/Databases/
        rm -r "${db_name}"
        echo "Database removed successfully"
    else
        echo "cannot remove Database ${db_name}:Database doesn't exist"
    fi
}

function connect_db_scenario () {
    read -r -p "Enter the database name: " db_name
    if [[ "$(is_db_exists "${db_name}/")" == "true" ]]; then
        echo "Database connected successfully"
        tables_level.sh ${db_name}
    else
        echo "cannot connect to Database ${db_name}:Database doesn't exist"
    fi
}

function list_dbs_scenario () {
    all_databases=$(ls -F ~/Desktop/Bash_Project/Databases/ | grep /)
    num_of_dbs=${#all_databases}

    if [[ num_of_dbs -gt 0 ]]; then
        for db in "${all_databases[@]}"; do
            echo "${db}"
        done
    elif [[ num_of_dbs -eq 0 ]]; then
        echo "No Databases created yet"
    fi
    
}



scheme_level_options=('Create_Database' 'Drop_Database' 'Connect_Database' 'List_Databases' 'Exit')

select opt in "${scheme_level_options[@]}"; do
   case "${opt}" in
    'Create_Database')
        create_db_scenario
    ;;
    'Drop_Database')
        drop_db_scenario
    ;;
    'Connect_Database')
        connect_db_scenario
    ;;
    'List_Databases')
        list_dbs_scenario
    ;;
    'Exit')
        break
    ;;
    *)
        echo "Invalid Input"
    ;;
   esac
   
done