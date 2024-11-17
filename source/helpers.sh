#!/usr/bin/env bash
#===============================================================================
#  helpers.sh — Unix shell helpers
#  Copyright (C) 2024 — Erwann Rogard
#  Released under GPL 3.0
#  See https://www.gnu.org/licenses/gpl-3.0.en.html
#===============================================================================

c_erw_rule='#==============================================================================='

erw_this="${BASH_SOURCE[0]}"
function erw_help
{
    local pattern="${c_erw_rule}"
    local string=$(sed -n "/^${pattern}$/,/^${pattern}$/p" "$erw_this")
    sed ":a; N; s/\(${pattern}\n\)\(${pattern}\)/\1/; ta; s/\n\{2,\}/\n/; P; D" <<< "${string}"
}
#===============================================================================
# erw_hash <trunc_digit> <string>
#===============================================================================
function erw_hash
{
    local trunc_digit="$1"
    [[ "$trunc_digit" =~ ^[[:digit:]]+$ ]]\
        || { echo "error: ${trunc_digit} not a digit"; exit 1; }
    local string="$2"
    [[ -z "$string" ]]\
        && { echo "error: empty string"; exit 1; } 
    echo "$string" |  md5sum | cut -d '-' -f1 | cut -c 1-"$trunc_digit"
}
declare -A c_erw_dns_regex_kv
c_erw_dns_regex_kv['local']='[[:alnum:]_.%+-]+'
c_erw_dns_regex_kv['at']='@'
c_erw_dns_regex_kv['sld']='[[:alnum:].-]+'
c_erw_dns_regex_kv['tld']='\.[[:alpha:]]{2,}'
declare -a c_erw_eml_regex_ar=('local' 'at' 'sld' 'tld')
#  declare -r c_erw_eml_regex
c_erw_eml_regex=$(for key in "${c_erw_eml_regex_ar[@]}";
                  do printf '%s' "${c_erw_dns_regex_kv[$key]}"; 
                  done)
#===============================================================================
# erw_eml_address_p <string>
#===============================================================================
function erw_eml_address_p
{
    local address="$1"
    local regex="^${c_erw_eml_regex}$" 
    [[ $address =~ $regex ]] 
}
#===============================================================================
# erw_fields_count <sep> <file>
#===============================================================================
function  erw_fields_count
{
    local sep="$1"
    local file="$2"
    awk -F"$sep" '{print NF}' "$file"
}
#===============================================================================
# erw_path_join <parent> <child>
#===============================================================================
function erw_path_join
{
    local parent="${1%/}"
    local child="$2"
    local format="error: %s is empty"
    [[ -z "$parent" ]] || { printf "$format" "$parent" ; exit 1; }
    [[ -z "$child" ]] || { printf "$format" "$child" ; exit 1; }
    echo "$parent/$child"
}
#===============================================================================
# erw_path_ext <prefix> <ext>
#===============================================================================
function erw_path_ext
{
    local prefix="$1"
    local ext="$2"
    echo "${prefix}.${ext}"
}
#===============================================================================
# erw_false
#===============================================================================
function erw_false
{
    false; echo "$?"
}
#===============================================================================
# erw_true
#===============================================================================
function erw_true
{
    true; echo "$?"
}
#===============================================================================
# erw_false_p
#===============================================================================
function erw_false_p
{
    (( $? == $(erw_false) ))
}
#===============================================================================
# erw_true_p
#===============================================================================
function erw_true_p
{
    (( $? == $(erw_true) ))
}
