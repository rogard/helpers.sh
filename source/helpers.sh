#!/usr/bin/env bash
#===============================================================================
#  helpers.sh — Unix shell helpers
#  Copyright (C) 2024-2025 — Erwann Rogard
#  Released under GPL 3.0
#  See https://www.gnu.org/licenses/gpl-3.0.en.html
#===============================================================================

#===============================================================================
# erw_help
# erw_help <file>
#===============================================================================
function erw_help 
{
    local file pattern string
    file="${1:-${BASH_SOURCE[0]}}"
    pattern='#'
    pattern+=$(printf '=%.0s' {1..81})
    string=$(sed -n "/^${pattern}$/,/^${pattern}$/p" "${file}")
    sed ":a; N; \
s/\(${pattern}\n\)\(${pattern}\)/\1/; \
  ta; \
  s/\n\{2,\}/\n/; \
  P; D" <<< "${string}"
}
declare -A c_erw_regex_ar
#===============================================================================
# c_erw_eml_regex_ar
# c_erw_regex_ar['eml']
#===============================================================================
c_erw_dns_regex_ar=(
    # local             at  sld              tld
    '[[:alnum:]_.%+-]+' '@' '[[:alnum:].-]+' '\.[[:alpha:]]{2,}'
)
c_erw_regex_ar['eml']=$(printf '%s' "${c_erw_dns_regex_ar[@]}")
#===============================================================================
# c_erw_regex_ar['path']
#===============================================================================
# https://stackoverflow.com/a/10047501
# https://stackoverflow.com/a/42036026
c_erw_regex_ar['path']='^[^[:cntrl:]]+$'
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
function erw_string_join {
    local ifs disjunct_ar
    ifs=$1; shift
    disjunct_ar=("${@}")
    (IFS="$ifs"; printf "%s" "${disjunct_ar[*]}")
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
