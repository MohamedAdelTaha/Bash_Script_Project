#! /bin/bash

selected_database=$1
cd ~/Desktop/Bash_Project/Databases/"${selected_database}"/
export PS3="$selected_database/>"

function is_tb_exists () {
    new_tb_name=$1
    all_tables=$(ls ~/Desktop/Bash_Project/Databases/"${selected_database}"/)
    found_flag="false"
    for tb in ${all_tables}; do
        if [[ "${tb}" == "${new_tb_name}" ]]; then
            found_flag="true"
            break
        fi
    done
    
    echo $found_flag
}
function check_if_val_exists () {
    used_tb=$1
    enterd_val=$2
    opt_num=$3
    awk -F : -v c_n=$opt_num -v val=$enterd_val 'BEGIN{found="no";} {if($c_n == val){found="yes";}} END{print found;}' ${used_tb}
}
function creat_tb_and_metadata () {
    tb_name=$1
    num_validity="false"
    while [[ $num_validity == "false" ]]; do
        read -r -p "Enter the number of columns: " num_of_col
        if [[ $num_of_col =~ ^[1-9]+$ ]]; then
            num_validity="true"
        else
            echo 'Enter a valid number'
        fi
    done
    data_types=('Integer' 'String')
    col_type='String'
    constraint_types=('Unique' 'Normal')
    col_const='Noraml'

    cd ~/Desktop/Bash_Project/Databases/"${selected_database}"/
    for((i=1;i<=num_of_col;i++)); do
        read -r -p "Enter the ${i}th column name: " col_name
        name_val=$(name_validity.sh "${col_name}")
        if [[ "${name_val}" == "success" ]]; then
            select d_type in "${data_types[@]}"; do
                opt_num=$REPLY
                if [[ $opt_num =~ ^[1-2] ]]; then
                    col_type=$d_type
                    break
                else
                    echo "Invalid input"
                fi
            done
            
            select c_type in "${constraint_types[@]}"; do
                opt_num=$REPLY
                if [[ $opt_num =~ ^[1-2] ]]; then
                    col_const=$c_type
                    break
                else
                    echo "Invalid input"
                fi
                
            done

            echo "${col_name}:${col_type}:${col_const}" >> ".${tb_name}_meta"
        else 
            echo "An error occurred (details --> ${name_val})"
            i=$((i-1))
        fi

    done
    touch "${tb_name}"
}
function create_table_scenario () {
    read -r -p "Enter the table name: " tb_name
    name_val=$(name_validity.sh "${tb_name}")
    if [[ "${name_val}" == "success" ]]; then
        if [[ "$(is_tb_exists "${tb_name}")" == "false" ]]; then
            creat_tb_and_metadata ${tb_name}
            echo "Table created successfully"
        else
            echo "cannot create Table ${db_name}: Table exists"
        fi
            
    else 
        echo "An error occurred (details --> ${name_val})"
    fi
}
function drop_table_scenario () {
    read -r -p "Enter the table name: " tb_name
    if [[ "$(is_tb_exists "${tb_name}")" == "true" ]]; then
        cd ~/Desktop/Bash_Project/Databases/"${selected_database}"/
        rm  "${tb_name}" ".${tb_name}_meta" 
        echo "Table removed successfully"
    else
        echo "cannot remove Table ${tb_name}:Table doesn't exist"
    fi
}
function list_tables_scenario () {
    all_tables=$(ls ~/Desktop/Bash_Project/Databases/"${selected_database}"/)
    num_of_tbs=${#all_tables}

    if [[ num_of_tbs -gt 0 ]]; then
        for tb in "${all_tables[@]}"; do
            echo "${tb}"
        done
    elif [[ num_of_tbs -eq 0 ]]; then
        echo "No tables created yet"
    fi
}
function select_all () {
    used_tb=$1
    awk -F : ' {print $0} ' ${used_tb}
}
function select_by_col () {
    used_tb=$1
    col_names=($(awk -F : '{ print $1; }' ".${used_tb}_meta"))
    arr_len=${#col_names[@]}
    echo "Enter The column number you want to search by"
    select col in "${col_names[@]}"; do
        opt_num=$REPLY
        if [[ $opt_num =~ ^[1-9]+$ && $opt_num -le $arr_len ]]; then
            read -r -p "Enter the value: " entered_val
            check_val_existence=$(check_if_val_exists ${used_tb} ${entered_val} ${opt_num})
            if [[ $check_val_existence == "yes" ]]; then
                awk -F : -v c_n=$opt_num -v val=$entered_val ' {if($c_n == val){print $0;}} ' ${used_tb}
                break
            else
                echo "This value doesn't exist"
            fi
        else
            echo 'Invalid Input'
        fi

    done
}

function select_table_scenario () {
    read -r -p "Enter the table name: " tb_name
    
    if [[ "$(is_tb_exists "${tb_name}")" == "true" ]]; then
        check_if_tb_empty=($(awk -F : '{print $0}' $tb_name))
        if [[ -n  $check_if_tb_empty ]]; then
            PS3="$selected_database/$tb_name>"
            echo "choose the way you wany to select with: "
            select_options=('select_all_data' 'select_by_column')
            select sel_opt in "${select_options[@]}"; do
                case "${sel_opt}" in
                    'select_all_data')
                        select_all ${tb_name}
                        break
                    ;;
                    'select_by_column')
                        select_by_col ${tb_name}
                        break
                    ;;
                    *)
                        echo "Invalid Input"
                    ;;
                esac
            done
        else
            echo "empty table!, there is no data to select"
        fi
        PS3="$selected_database/>"
    else
        echo "Table ${tb_name} doesn't exist"
    fi

}
function insert_table_scenario () {
    read -r -p "Enter the table name: " tb_name
    PS3="$selected_database/$tb_name>"
    if [[ "$(is_tb_exists "${tb_name}")" == "true" ]]; then
        col_names=($(awk -F : '{ print $1; }' ".${tb_name}_meta"))
        contraints=($(awk -F : '{ print $3; }' ".${tb_name}_meta"))
        len=${#col_names[@]}
        cd ~/Desktop/Bash_Project/Databases/"${selected_database}"/
        
        for((i=1;i<=len;i++)); do
            read -r -p "Enter a value in ${col_names[$((i-1))]} column: " val
            curr_const=${contraints[$((i-1))]}
            message="not_found"
            if [[ $curr_const == "Unique" ]]; then
                message=$(awk -F : -v var=$val ' BEGIN{exist="not_found";} { if($1==var){exist="found";} } END{print exist;}' $tb_name)
            fi

            if [[ $message == "found" ]]; then
                echo "This unique value already exists"
                i=$((i-1))
            else
                if (($i < len)); then
                    printf "%s:" "${val}" >> ${tb_name}
                elif (($i == len)); then
                    printf "%s\n" "${val}" >> ${tb_name}
                fi
            fi
            
        done

        echo "Record inserted successfully"
    else
        echo "Table ${tb_name} doesn't exist"
    fi

    PS3="$selected_database/>"
}
function delete_all () {
    used_tb=$1
    sed -i 'd' ${used_tb}
}
function delete_by_col () {
    used_tb=$1
    col_names=($(awk -F : '{ print $1; }' ".${used_tb}_meta"))
    arr_len=${#col_names[@]}
    echo "Enter The column number you want to delete by"
    select col in "${col_names[@]}"; do
        opt_num=$REPLY
        if [[ $opt_num =~ ^[1-9]+$ && $opt_num -le $arr_len ]]; then
            read -r -p "Enter the value: " entered_val
            check_val_existence=$(check_if_val_exists ${used_tb} ${entered_val} ${opt_num})
            if [[ $check_val_existence == "yes" ]]; then
                output=$(awk -F : -v c_n=$opt_num -v val=$entered_val '{if($c_n == val){print NR;}}' ${used_tb} | tr "\n" ",")
                new_output=${output%,}d
                sed -i "$new_output" ${used_tb}
                break
            else
                echo "This value doesn't exist"
            fi
        else    
            echo 'Invalid Input'
        fi

    done
}
function delete_table_scenario () {
    read -r -p "Enter the table name: " tb_name
    PS3="$selected_database/$tb_name>"
    if [[ "$(is_tb_exists "${tb_name}")" == "true" ]]; then
        echo "choose the way you wany to delete by: "
        delete_options=('delete_the_entire_data' 'delete_by_column')
        select del_opt in "${delete_options[@]}"; do
            case "${del_opt}" in
                'delete_the_entire_data')
                    delete_all ${tb_name}
                    break
                ;;
                'delete_by_column')
                    delete_by_col ${tb_name}
                    break
                ;;
                *)
                    echo "Invalid Input"
                ;;
            esac
        done
        echo "Delete done successfully"
    else
        echo "Table ${tb_name} doesn't exist"
    fi

    PS3="$selected_database/>"
}
function update_table_scenario () {
    read -r -p "Enter the table name: " used_tb
    
    if [[ "$(is_tb_exists "${used_tb}")" == "true" ]]; then
        check_if_tb_empty=($(awk -F : '{print $0}' $used_tb))
        if [[ -n  $check_if_tb_empty ]]; then
            PS3="$selected_database/$used_tb>"
            col_names=($(awk -F : '{ print $1; }' ".${used_tb}_meta"))
            contraints=($(awk -F : '{ print $3; }' ".${tb_name}_meta"))
            arr_len=${#col_names[@]}
            echo "Enter The column number you want to update the value in"
            select col in "${col_names[@]}"; do
                opt_num=$REPLY
                if [[ $opt_num =~ ^[1-9]+$ && $opt_num -le $arr_len ]]; then
                    curr_const=${contraints[$opt_num]}
                    read -r -p "Enter the old value you want to change: " old_val
                    check_val_existence=$(check_if_val_exists ${used_tb} ${old_val} ${opt_num})
                    if [[ $check_val_existence == "yes" ]]; then
                        read -r -p "Enter the new value you want to update: " new_val
                        message="not_found"
                        if [[ $curr_const == "Unique" ]]; then
                            message=$(awk -F : -v var=$new_val ' BEGIN{exist="not_found";} { if($1==var){exist="found";} } END{print exist;}' $tb_name)
                        fi
                        if [[ $message == "found" ]]; then
                            echo "This unique value already exists"
                        else
                            awk -F : -v c_n=$opt_num -v o_val=$old_val -v n_val=$new_val 'BEGIN {OFS=FS} {if($c_n==o_val){$c_n=n_val}print $0;} ' ${used_tb} > tmp_file && mv tmp_file ${used_tb}
                            echo "Table updated succesfully"
                            break
                        fi 
                    else
                        echo "This value doesn't exist"
                    fi
                else
                    echo 'Invalid Input'
                fi
            done
        else
            echo "empty table!, there is no data to update"
        fi
        PS3="$selected_database/>"
    else
        echo "Table ${tb_name} doesn't exist"
    fi
}

table_level_options=('Create_Table' 'Drop_Table' 'List_Tables' 'Select_Table' 'Insert_Table' 'Delete_Table' 'Update_Table' 'Return_to_Databases_level')
rtn_to_db_level="false"
select opt in "${table_level_options[@]}"; do
   case "${opt}" in
    'Create_Table')
        create_table_scenario
    ;;
    'Drop_Table')
        drop_table_scenario
    ;;
    'List_Tables')
        list_tables_scenario
    ;;
    'Select_Table')
        select_table_scenario
    ;;
    'Insert_Table')
        insert_table_scenario
    ;;
    'Delete_Table')
        delete_table_scenario
    ;;
    'Update_Table')
        update_table_scenario
    ;;
    'Return_to_Databases_level')
        rtn_to_db_level='true'
        break
    ;;
    *)
        echo "Invalid Input"
    ;;
   esac
done

if [[ $rtn_to_db_level == 'true' ]]; then
    databases_level.sh
fi
