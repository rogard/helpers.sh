#!/usr/bin/env bash
#===============================================================================
#  helpers.sh — Unix shell helpers
#  Copyright (C) 2024-2025 — Erwann Rogard
#  Released under GPL 3.0
#  See https://www.gnu.org/licenses/gpl-3.0.en.html
#===============================================================================

c_erw_rule='#==============================================================================='

erw_this="${BASH_SOURCE[0]}"
function erw_help
(
    pattern="${c_erw_rule}"
    string=$(sed -n "/^${pattern}$/,/^${pattern}$/p" "$erw_this")
    sed ":a; N; s/\(${pattern}\n\)\(${pattern}\)/\1/; ta; s/\n\{2,\}/\n/; P; D" <<< "${string}"
)
#===============================================================================
# c_erw_eml_regex_ar
# c_erw_eml_regex
#===============================================================================
c_erw_dns_regex_ar=(
    # local             at  sld              tld
    '[[:alnum:]_.%+-]+' '@' '[[:alnum:].-]+' '\.[[:alpha:]]{2,}'
)
c_erw_eml_regex=$(printf '%s' "${c_erw_dns_regex_ar[@]}")
#===============================================================================
# c_erw_path_regex
#===============================================================================
# Xref:
# https://stackoverflow.com/a/10047501
# https://stackoverflow.com/a/42036026
c_erw_path_regex='^[^[:cntrl:]]+$'
#===============================================================================
# erw_path_p <string>
#===============================================================================
function erw_path_p
{
    local string
    string="${1}"
    [[ "$string" =~ ^${c_erw_path_regex}$ ]]
}
#===============================================================================
# erw_eml_address_p <string>
#===============================================================================
function erw_eml_address_p
(
    string="${1}"
    [[ "${string}" =~ ^${c_erw_eml_regex}$ ]] 
)
#===============================================================================
# erw_exit_ok_p
#===============================================================================
function erw_exit_ok_p
{
    (( $? == 0 ))
}
#===============================================================================
# erw_fields_count <sep> <file>
#===============================================================================
function erw_fields_count
{
    local sep file
    sep="$1"
    file="$2"
    awk -F"$sep" '{print NF}' "$file"
}
#===============================================================================
# erw_path_join <parent> <child>
#===============================================================================
function erw_path_join
{
    local parent child result
    parent="${1%/}"
    child="${2#/}"
    result="${parent}/${child}"
    erw_path_p "${result}" \
	|| {
	format='%s does not match %s';
	printf "$format" "$result" "";
	return 1;
    }
    echo "${result}"
}
#===============================================================================
# erw_hash <trunc_digit> <string>
#===============================================================================
function erw_hash
{
    local string
    string="$1"
    [[ -z "$string" ]]\
        && { echo "empty string"; return 1; } 
    echo "$string" |  md5sum | cut -d '-' -f1 # | cut -c 1-"$digit"
}
#===============================================================================
# erw_tex_safe <string>
#===============================================================================
function erw_tex_safe
{
    local string
    string="${1}"
    echo "${string}" | sed 's/_/\\_/g'
}
