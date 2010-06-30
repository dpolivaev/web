
class KataController < ApplicationController

  def index
    @dojo = Dojo.new(params[:dojo])
    @avatars = Avatar.names
    @languages = Language.names
    @katas = Kata.names
  end

  def view
    @dojo = Dojo.new(params[:dojo])
    @avatar = Avatar.new(@dojo, params[:avatar])
    @kata = Kata.new(params[:language], params[:kata])

    @manifest = {}
    @increments = limited(@avatar.read_most_recent(@kata, @manifest))
    @current_file = @manifest[:current_filename] || 'cyberdojo.sh'
    @output = @manifest[:output] || welcome_text
    @output_outcome = @increments == [] ? '' : @increments.last[:outcome]
  end

  def run_tests
    dojo = Dojo.new(params[:dojo])
    avatar = Avatar.new(dojo, params[:avatar])
    kata = Kata.new(params[:language], params[:kata])

    @output = avatar.run_tests(kata, load_files_from_page)
    @increments = limited(avatar.increments)
    @output_outcome = @increments.last[:outcome]
    respond_to do |format|
      format.js if request.xhr?
    end
  end
  
  def money_ladder
    respond_to do |format|
      format.js if request.xhr?
    end
  end

private

  def welcome_text
    [ 'Welcome.',
      '',
      'CyberDojo: practicing the collaborative game',
      'called software development!',
      '',      
      'Clicking the play> button runs cyberdojo.sh on the',
      'CyberDojo server and displays its output here.',
      '',
      'The Only CyberDojo Rule',
      '-----------------------',
      'When you hear the bell each keyboard driver must move',
      'to another laptop and take up a non-driver role.',
    ].join("\n")
  end

  def dequote(filename)
    # <input name="file_content['wibble.h']" ...>
    # means filename has a leading ' and trailing ']
    # which need to be stripped off
    return filename[1..-2] 
  end

  def load_files_from_page
    manifest = { :visible_files => {} }

    (params[:file_content] || {}).each do |filename,content|
      filename = dequote(filename)
      manifest[:visible_files][filename] = {}
      manifest[:visible_files][filename][:content] = content.split("\r\n").join("\n")  
    end

    (params[:file_caret_pos] || {}).each do |filename,caret_pos|
      filename = dequote(filename)
      manifest[:visible_files][filename][:caret_pos] = caret_pos
    end

    manifest[:current_filename] = params['filename']

    manifest
  end

end

def limited(increments)
  max_increments_displayed = 6
  len = [increments.length, max_increments_displayed].min
  increments[-len,len]
end




