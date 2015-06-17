$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "yard-dash/setup"
require "yard-dash/base_helper"
require "yard-dash/version"

# Setup the yard-dash override directory
YardDashSetup::setup_override
# Add the template helper
Template.extra_includes << YardDashHelper
# Override the default template for the given file
YARD::Templates::Engine.register_template_path YardDashSetup::tmpdir

