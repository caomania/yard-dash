require "tmpdir"

#
# Module YardDashSetup provides the setup logic for yard-dash
#
# @author Fred Appelman <fred@appelman.net>
#
module YardDashSetup
  module_function

  #
  # @return [String] The file in the yad package that needs patching
  ERB = 'full_list.erb'

  #
  # Create a temporary directory. This directory is constant
  # during a run and is removed when the application exits.
  #
  #
  # @return [String] The name of the created directory
  #
  def tmpdir
    @tmpdir ||= begin
      Dir.mktmpdir
    end
  end


  #
  # Setup the override of the erb file. We copy one file from
  # the standard yard directory and copy that file to a temporary
  # directory after which the copied file is patched. A few hooks
  # that trigger the logic in the base_helper file.
  #
  #
  # @return [void]
  #
  def setup_override
    spec = Gem::Specification.find_by_name 'yard'
    erb = File.join(spec.gem_dir,"templates","default","fulldoc","html",ERB)
    # Create the subdirectory structure
    subdir = File.join(tmpdir,"default","fulldoc","html")
    FileUtils.mkdir_p subdir
    # Copy the erb
    target_file = File.join(subdir,ERB)
    FileUtils.cp(erb,target_file)
    # Open the file and add the anchors
    open(target_file,'a') do |file|
      file.write "<% do_dash %>\n"
    end
  end

  # Remove the directory at the end of the run
  END {
    # Remove the temp directory
    FileUtils.rm_rf tmpdir
  }
end
