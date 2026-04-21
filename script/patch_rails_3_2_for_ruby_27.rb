#!/usr/bin/env ruby
# Patch Rails 3.2.22 for Ruby 2.7+ compatibility
# Fixes circular argument reference errors

def patch_timezone
  file_path = "vendor/bundle/ruby/2.7.0/gems/activesupport-3.2.22/lib/active_support/values/time_zone.rb"

  unless File.exist?(file_path)
    puts "TimeZone file not found: #{file_path}"
    return
  end

  content = File.read(file_path)

  if content.include?('def parse(str, now_time=nil)')
    puts "TimeZone already patched for Ruby 2.7"
    return
  end

  puts "Patching TimeZone for Ruby 2.7 compatibility..."

  content.gsub!(
    /def parse\(str, now=now\)/,
    "def parse(str, now_time=nil)\n      now_time ||= now"
  )
  content.gsub!(
    /Time\.parse\(str, now\) rescue DateTime\.parse\(str\)/,
    'Time.parse(str, now_time) rescue DateTime.parse(str)'
  )

  File.write(file_path, content)
  puts "TimeZone patch applied successfully"
end

def patch_has_many
  file_path = "vendor/bundle/ruby/2.7.0/gems/activerecord-3.2.22/lib/active_record/associations/has_many_association.rb"

  unless File.exist?(file_path)
    puts "HasManyAssociation file not found: #{file_path}"
    return
  end

  content = File.read(file_path)

  if content.include?('reflection_param')
    puts "HasManyAssociation already patched for Ruby 2.7"
    return
  end

  puts "Patching HasManyAssociation for Ruby 2.7 compatibility..."

  # Fix has_cached_counter?
  content.gsub!(
    /def has_cached_counter\?\(reflection = reflection\)/,
    "def has_cached_counter?(refl = nil)\n        refl ||= reflection"
  )
  content.gsub!(
    /has_cached_counter\?\(reflection\)/,
    'has_cached_counter?(refl)'
  )

  # Fix cached_counter_attribute_name
  content.gsub!(
    /def cached_counter_attribute_name\(reflection = reflection\)/,
    "def cached_counter_attribute_name(refl = nil)\n        refl ||= reflection"
  )
  content.gsub!(
    /cached_counter_attribute_name\(reflection\)/,
    'cached_counter_attribute_name(refl)'
  )
  # Fix the one call that uses "reflection" variable
  content.gsub!(
    /"#\{reflection\.name\}_count"/,
    '"#{refl.name}_count"'
  )

  # Fix update_counter
  content.gsub!(
    /def update_counter\(difference, reflection = reflection\)/,
    "def update_counter(difference, refl = nil)\n        refl ||= reflection"
  )

  # Fix inverse_updates_counter_cache?
  content.gsub!(
    /def inverse_updates_counter_cache\?\(reflection = reflection\)/,
    "def inverse_updates_counter_cache?(refl = nil)\n        refl ||= reflection"
  )
  # Update the body to use refl variable
  content.gsub!(
    /reflection\.klass\.reflect_on_all_associations/,
    'refl.klass.reflect_on_all_associations'
  )

  # Fix delete_records
  content.gsub!(
    /def delete_records\(records, method = method\)/,
    "def delete_records(records, meth = nil)\n        meth ||= method"
  )
  content.gsub!(
    /^(\s+)case method$/,
    '\1case meth'
  )

  File.write(file_path, content)
  puts "HasManyAssociation patch applied successfully"
end

def patch_arel_3_0
  # Rails 3.2 uses Arel 3.0, which needs Integer/Fixnum visitor support
  file_path = "vendor/bundle/ruby/2.7.0/gems/arel-3.0.3/lib/arel/visitors/to_sql.rb"

  unless File.exist?(file_path)
    puts "Arel 3.0 visitor file not found: #{file_path}"
    return
  end

  content = File.read(file_path)

  if content.include?('visit_Integer')
    puts "Arel 3.0 visitor already patched for Integer support"
    return
  end

  puts "Patching Arel 3.0 visitor for Integer/Fixnum support..."

  # Arel 3.0 wraps integers in SqlLiteral nodes, so we need to handle them properly
  patch = <<~RUBY

    # Patch for Ruby 2.7+ where Fixnum is unified with Integer
    def visit_Integer o
      visit_Arel_Nodes_SqlLiteral(Arel::Nodes::SqlLiteral.new(o.to_s))
    end

    # Preserve Fixnum support for older Ruby versions
    def visit_Fixnum o
      visit_Arel_Nodes_SqlLiteral(Arel::Nodes::SqlLiteral.new(o.to_s))
    end
  RUBY

  File.write(file_path, content + patch)
  puts "Arel 3.0 visitor patch applied successfully"
end

# Run all patches
patch_timezone
patch_has_many
patch_arel_3_0
