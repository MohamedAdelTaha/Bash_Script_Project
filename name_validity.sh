#! /bin/bash

shopt -s extglob

arr_of_special_chars=("'" '*' '?' '!' ' ' '"' '#' '$' '%' '&'  '(' ')' '+' ',' '-' '.' '/' '\' ':' ';' '<' '=' '>' '@' '[' ']' '^' '`' '{' '|' '}' '~')
first_arg=$1

function first_is_digit () {
    name=$1
    first_char=${name:0:1}
   case "${first_char}" in
    +([0-9]) )
        echo "true"
    ;;
    *)
        echo "false"
    ;;
   esac
}

function contains_spec_char () {
    name=$1
    if [[ -z $name ]]; then
         echo "There is no input, Please Enter a valid name"
    elif [[ -n $name ]]; then
         flag='false'
         name_len=${#name}
         spec_char_len=${#arr_of_special_chars[@]}
         for((i=0;i<name_len;i++)); do
             for((j=0;j<spec_char_len;j++)); do
                 if [[ ${name:$i:1} == "${arr_of_special_chars[j]}" ]]; then
                     flag='true'
                     echo 'true'
                     break
                 fi
             done
         done
         if [[ $flag == 'false' ]]; then
         echo 'false'
         fi
    fi
}

function name_validation() {
    if [[ -z $first_arg ]]; then
        echo "There is no input, Please Enter a valid name"
    elif [[ -n $first_arg ]]; then

        if [[ "$(first_is_digit "${first_arg}")" == "true" ]]; then
            echo "The first char cannot be digit"
        elif [[ "$(first_is_digit "${first_arg}")" == "false" ]]; then
            if [[ "$(contains_spec_char "${first_arg}")" == "true" ]]; then
                echo "special characters are invaild"
            elif [[ "$(contains_spec_char "${first_arg}")" == "false" ]]; then
                echo "success"
            fi
            
        fi
        
    fi
}

name_validation