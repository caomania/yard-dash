include YARD
include Templates
require "sqlite3"

#
# Module YardDashHelper provides the logic to create the Dash
# docset.
#
# @author Fred Appelman <fred@appelman.net>
#
module YardDashHelper

  # @return [String] The name of the subdirectory in the docset Documents
  #   directory
  DOC_DIR = "docs"

  # @return [String] The suffix for a dash docset
  DOC_SET = ".docset"

  # The tags found during scanning
  @@docset_data = []

  #
  # Convert a name as return by the AST parser into a name
  # suitable for the documentation.
  # @example
  #   'GemLogic.gem_lib_dir' => 'GemLogic'
  # @example
  #   'PidFile#release' => 'PidFile'
  # @example
  #   'XmlSimple::Cache#get_from_memory_cache' => 'XmlSimple/Cache'
  #
  # @param [<Yardoc class>,<Yardoc constant>, <Yardoc method>,
  #   <Yardoc module>] m The class/constant/method/module to convert
  #
  # @return [String] The converted name
  #
  def transpose(m)
    base_name = m.to_s.gsub(%r{\..*$},"")
    base_name = base_name.gsub(%r{#.*$},"")
    base_name.gsub(%r[::],"/")
  end
  private :transpose


  #
  # Return the full HTML path given the class/constant/method or module m.
  #
  # @param [<Yardoc class>,<Yardoc constant>, <Yardoc method>,
  #   <Yardoc module>] m The class/constant/method/module to convert
  #
  # @return [String] The full path
  #
  def html_path(m)
    base_name = transpose(m)
    "#{DOC_DIR}/" + base_name + ".html"
  end
  private :html_path

  #
  # Return the readable name for the supplied class/constant/method
  # or module m.
  #
  # @param [<Yardoc class>,<Yardoc constant>, <Yardoc method>,
  #   <Yardoc module>] m The class/constant/method/module to convert
  #
  # @return [String] The readable path
  #
  def name(m)
    case m.scope
    when :instance
      m.to_s.sub(%r{#([^#]*?)$},'.\1')
    when :class
      m.to_s
    else
      abort("Scope: #{m.scope} unknown")
    end
  end
  private :name

  # Called by the ERB to process all methods in the Registry.
  #
  # @return [void]
  #
  def all_methods
    Registry.all(:method).map do |m|
      t = if m.to_s.match(/^#/)
        # Top level namespace
        [name(m), "Method", "#{DOC_DIR}/top-level-namespace.html" + '#' + "#{m.name}-#{m.scope}_method"]
      else
        [name(m), "Method", html_path(m) + '#' + "#{m.name}-#{m.scope}_method"]
      end
      @@docset_data << t unless @@docset_data.include?(t)
    end
  end
  private :all_methods


  # Called by the ERB to process all classes in the Registry.
  #
  # @return [void]
  #
  def all_classes
    Registry.all(:class).map do |m|
      t = [m.to_s, "Class", html_path(m)]
      @@docset_data << t unless @@docset_data.include?(t)
    end
  end
  private :all_classes

  # Called by the ERB to process all modules in the Registry.
  #
  # @return [void]
  #
  def all_modules
    Registry.all(:module).map do |m|
      t = [m.to_s, "Module", html_path(m)]
      @@docset_data << t unless @@docset_data.include?(t)
    end
  end
  private :all_modules

  # Called by the ERB to process all constants in the Registry.
  #
  # @return [void]
  #
  def all_constants
    Registry.all(:constant).map do |m|
      # This is an example of a constant:
      #    Vlogger::Severity::SEVERITY_TO_COLOR
      # The name of the constant is as above. The name of the file
      # is the Vlogger/Severity.html
      t = [m.to_s, "Constant", "#{DOC_DIR}/" + transpose(m).sub(%r{/[^/]*?$},"") + ".html"]
      @@docset_data << t unless @@docset_data.include?(t)
    end
  end
  private :all_constants

  #
  # Return a plist as a string
  #
  # @param [String] package The name of the package
  #
  # @return [String] The plist
  #
  def plist(package)
    <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>
  <string>#{package}</string>
  <key>CFBundleName</key>
  <string>#{package}</string>
  <key>DocSetPlatformFamily</key>
  <string>ruby</string>
  <key>isDashDocset</key>
  <true/>
</dict>
</plist>
      XML
  end
  private :plist

  #
  # Write the docset
  #
  # @return [void]
  #
  def write_docset
    gemspecs = Dir[%q{*.gemspec}]
    abort("Cannot find gemspec file") if gemspecs.size == 0
    abort("Too many gemspec files ") if gemspecs.size > 1
    package = gemspecs.shift.gsub(".gemspec",'')
    target = package + ".docset"
    # Remove the previous content
    FileUtils.rm_rf(target) if Dir.exist?(target)
    # Create the docset
    FileUtils.mkdir_p(target)
    FileUtils.mkdir_p(target + '/' + 'Contents/Resources/Documents/')
    # Create Info.plist file
    plist = plist(package)
    File.open(target + '/Contents/Info.plist', 'w+') { |file| file.write plist }
    # Copy the doc directory
    new_doc_path  = target + '/Contents/Resources/Documents/'
    FileUtils.cp_r "doc", new_doc_path
    FileUtils.mv File.join(new_doc_path,"doc"), File.join(new_doc_path,"docs")
    # Create the database
    @db = SQLite3::Database.new(target + '/Contents/Resources/docSet.dsidx')
    @db.execute('CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT)')
    @db.execute('CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path)')
    # Add the methods, classes, modules and constants
    @@docset_data.each do |docset_element|
      @db.execute("insert into searchIndex (name, type, path) VALUES(?, ?, ?)",*docset_element)
      FileUtils.cp path File.join(new_doc_path,"doc")
    end
  end
  private :write_docset


  #
  # Process all constants, classes, methods and modules and
  # write the docset.
  #
  # @return [<type>] <description>
  #
  def do_dash
    all_constants
    all_classes
    all_methods
    all_modules
    write_docset
  end

end




