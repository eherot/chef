When "I upload the '$cookbook_name' cookbook with knife" do |cookbook_name|
  cookbook_fixture = File.join(FEATURES_DATA, "cookbooks_not_uploaded_at_feature_start", cookbook_name)
  cookbook_dir = ::Tempfile.open("knife-cuke-cookbook-dir").path
  FileUtils.rm(cookbook_dir)
  #cookbook_tmp_location = File.join(cookbook_dir, cookbook_name)
  FileUtils.mkdir_p(cookbook_dir)
  FileUtils.cp_r(cookbook_fixture, cookbook_dir)
  cmd = shell_out!("#{KNIFE_CMD} cookbook upload #{cookbook_name} -o #{cookbook_dir} -c #{KNIFE_CONFIG} -l debug")
  puts cmd.format_for_exception
end
