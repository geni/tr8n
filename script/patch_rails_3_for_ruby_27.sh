#!/bin/sh
# Patch Rails 3.0.20 for Ruby 2.7+ compatibility
# This fixes multiple Ruby 2.7+ incompatibilities

TIMEZONE_FILE="vendor/bundle/ruby/2.7.0/gems/activesupport-3.0.20/lib/active_support/values/time_zone.rb"
BIGDECIMAL_FILE="vendor/bundle/ruby/2.7.0/gems/activesupport-3.0.20/lib/active_support/core_ext/big_decimal/conversions.rb"

# Patch 1: Fix TimeZone#parse circular argument reference
if [ -f "$TIMEZONE_FILE" ]; then
  # Check if already patched
  if grep -q "def parse(str, now_time=nil)" "$TIMEZONE_FILE"; then
    echo "TimeZone already patched for Ruby 2.7"
  else
    echo "Patching TimeZone for Ruby 2.7 compatibility..."
    # Use perl for more reliable multi-line substitution
    perl -i -pe 's/def parse\(str, now=now\)/def parse(str, now_time=nil)\n      now_time ||= now/' "$TIMEZONE_FILE"
    perl -i -pe 's/time = Time\.parse\(str, now\) rescue DateTime\.parse\(str\)/time = Time.parse(str, now_time) rescue DateTime.parse(str)/' "$TIMEZONE_FILE"
    echo "TimeZone patch applied successfully"
  fi
fi

# Patch 2: Fix BigDecimal yaml_as -> yaml_tag
if [ -f "$BIGDECIMAL_FILE" ]; then
  if grep -q "yaml_tag" "$BIGDECIMAL_FILE"; then
    echo "BigDecimal already patched for Ruby 2.7"
  else
    echo "Patching BigDecimal for Ruby 2.7 compatibility..."
    sed -i 's/yaml_as/yaml_tag/' "$BIGDECIMAL_FILE"
    echo "BigDecimal patch applied successfully"
  fi
fi
