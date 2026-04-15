#!/bin/bash

# Script to generate fst-variants.json with information about available variants
# Usage: make-fst-variants-json.sh [OPTIONS]
#   --dialects "Jok Por Var"
#   --areas "NO SE"
#   --orthographies "macron circumfl"
#   --default-orth "circumfl"
#   --writing-systems "Latn Cans"
#   --default-ws "Latn"
#   --build-config path/to/.build-config.yml
#   --output filename.json

set -e

# Default values
DIALECTS=""
AREAS=""
ORTHOGRAPHIES=""
WRITING_SYSTEMS=""
DEFAULT_WS=""
DEFAULT_ORTH=""
BUILD_CONFIG=""
OUTPUT="fst-variants.json"
WANT_DIALECT_PROOFTOOLS="no"
WANT_ALT_ORTH_PROOFTOOLS="no"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dialects)
            DIALECTS="$2"
            shift 2
            ;;
        --areas)
            AREAS="$2"
            shift 2
            ;;
        --orthographies)
            ORTHOGRAPHIES="$2"
            shift 2
            ;;
        --default-orth)
            DEFAULT_ORTH="$2"
            shift 2
            ;;
        --writing-systems)
            WRITING_SYSTEMS="$2"
            shift 2
            ;;
        --default-ws)
            DEFAULT_WS="$2"
            shift 2
            ;;
        --want-dialect-prooftools)
            WANT_DIALECT_PROOFTOOLS="$2"
            shift 2
            ;;
        --want-alt-orth-prooftools)
            WANT_ALT_ORTH_PROOFTOOLS="$2"
            shift 2
            ;;
        --build-config)
            BUILD_CONFIG="$2"
            shift 2
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Read build config to determine has_speller and has_grammar_checker
HAS_SPELLERS=false
HAS_GRAMCHECK=false

if [ -f "$BUILD_CONFIG" ]; then
    # Parse YAML file - only look at the build: section
    # Read until we hit 'build:', then read until next top-level section or EOF
    in_build_section=false
    while IFS= read -r line; do
        # Check if we're entering the build section
        if [[ "$line" =~ ^build: ]]; then
            in_build_section=true
            continue
        fi
        # Check if we've hit another top-level section (not indented)
        if [[ "$line" =~ ^[a-z] ]] && [ "$in_build_section" = true ]; then
            # We've left the build section
            break
        fi
        # If we're in build section, check for our values
        if [ "$in_build_section" = true ]; then
            if [[ "$line" =~ spellers:.*true ]]; then
                HAS_SPELLERS=true
            fi
            if [[ "$line" =~ grammar-checkers:.*true ]]; then
                HAS_GRAMCHECK=true
            fi
        fi
    done < "$BUILD_CONFIG"
fi

# Determine has_speller/has_grammar_checker for each variant type
# based on WANT_*_PROOFTOOLS flags
if [ "$WANT_DIALECT_PROOFTOOLS" = "yes" ]; then
    DIALECT_HAS_SPELLERS=$HAS_SPELLERS
    DIALECT_HAS_GRAMCHECK=$HAS_GRAMCHECK
else
    DIALECT_HAS_SPELLERS=false
    DIALECT_HAS_GRAMCHECK=false
fi

if [ "$WANT_ALT_ORTH_PROOFTOOLS" = "yes" ]; then
    ORTH_HAS_SPELLERS=$HAS_SPELLERS
    ORTH_HAS_GRAMCHECK=$HAS_GRAMCHECK
else
    ORTH_HAS_SPELLERS=false
    ORTH_HAS_GRAMCHECK=false
fi

# Areas always use the build config (no separate WANT flag)
AREA_HAS_SPELLERS=$HAS_SPELLERS
AREA_HAS_GRAMCHECK=$HAS_GRAMCHECK

# Writing systems always use the build config (no separate WANT flag)
WS_HAS_SPELLERS=$HAS_SPELLERS
WS_HAS_GRAMCHECK=$HAS_GRAMCHECK

# Function to generate JSON array for variants
generate_variant_array() {
    local variants="$1"
    local variant_type="$2"
    local default_code="$3"
    local has_spellers="$4"
    local has_gramcheck="$5"
    
    if [ -z "$variants" ]; then
        echo -n "null"
        return
    fi
    
    echo -n "["
    local first=true
    for variant in $variants; do
        if [ "$first" = true ]; then
            first=false
        else
            echo -n ", "
        fi
        
        # Determine if this is the default variant
        local is_default=false
        if [ -n "$default_code" ] && [ "$variant" = "$default_code" ]; then
            is_default=true
        fi
        
        echo -n '{"code": "'$variant'"'
        
        if [ "$is_default" = true ]; then
            echo -n ', "default": true'
        fi
        
        echo -n ', "has_speller": '$has_spellers
        echo -n ', "has_grammar_checker": '$has_gramcheck
        echo -n '}'
    done
    echo -n "]"
}

# Generate JSON structure
{
    echo "{"
    
    # Dialects
    echo -n '  "dialects": '
    generate_variant_array "$DIALECTS" "dialect" "" "$DIALECT_HAS_SPELLERS" "$DIALECT_HAS_GRAMCHECK"
    echo ","
    
    # Areas
    echo -n '  "areas": '
    generate_variant_array "$AREAS" "area" "" "$AREA_HAS_SPELLERS" "$AREA_HAS_GRAMCHECK"
    echo ","
    
    # Orthographies
    echo -n '  "orthographies": '
    generate_variant_array "$ORTHOGRAPHIES" "orthography" "$DEFAULT_ORTH" "$ORTH_HAS_SPELLERS" "$ORTH_HAS_GRAMCHECK"
    echo ","
    
    # Writing systems
    echo -n '  "writing_systems": '
    generate_variant_array "$WRITING_SYSTEMS" "writing_system" "$DEFAULT_WS" "$WS_HAS_SPELLERS" "$WS_HAS_GRAMCHECK"
    echo ""
    
    echo "}"
} > "$OUTPUT"

# Pretty-print with jq if available
if command -v jq > /dev/null 2>&1; then
    jq . "$OUTPUT" > "$OUTPUT.tmp" && mv "$OUTPUT.tmp" "$OUTPUT"
fi
