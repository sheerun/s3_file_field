require 'spec_helper'

module S3FileField
  describe S3Uploader do
    before(:each) do
      S3FileField.config.access_key_id = "key"
      S3FileField.config.secret_access_key = "secret"
      S3FileField.config.bucket = "bucket"
    end

    context '#new' do
      it 'accepts possibly no parameters' do
        S3Uploader.new
      end

      it 'raises an exception if no aws key is set' do
        S3FileField.config.access_key_id = nil

        expect {
          S3Uploader.new
        }.to raise_error(Error)
      end

      it 'raises an exception if no aws secret is set' do
        S3FileField.config.secret_access_key = nil

        expect {
          S3Uploader.new
        }.to raise_error(Error)
      end

      it 'raises an exception if no bucket is set' do
        S3FileField.config.bucket = nil

        expect {
          S3Uploader.new
        }.to raise_error(Error)
      end

      it 'allows for overwriting defaults' do
        S3FileField.config.access_key_id = nil
        S3Uploader.new(:access_key_id => "foo")
      end

      it 'overwrites defaults' do
        S3FileField.config.access_key_id = nil
        uploader = S3Uploader.new(:access_key_id => "foo")
        expect(uploader.options[:access_key_id]).to eq("foo")
      end
    end

    context '#field_data_options' do
      it 'should return defaults by default' do
        s3_uploader = S3Uploader.new({})
        expect(s3_uploader.field_data_options[:acl]).to eq("public-read")
      end

      it 'recognizes overwritten defaults' do
        s3_uploader = S3Uploader.new(:acl => "foo")
        expect(s3_uploader.field_data_options[:acl]).to eq("foo")
      end

      it 'should generate default random key' do
        s3_uploader = S3Uploader.new
        mask = /uploads\/{timestamp\}-\{unique_id\}-\w+\/\${filename}/
        expect(s3_uploader.field_data_options[:key]).to match(mask)
      end

      it 'allows for overriding default key' do
        s3_uploader = S3Uploader.new(:key => "/uploads/foobar")
        expect(s3_uploader.field_data_options[:key]).to match("/uploads/foobar")
      end

      it 'should not render new lines in any value' do
        S3Uploader.new.field_data_options.each do |k, v|
          expect(v).to_not include("\n")
        end
      end
    end

    describe "url" do
      it "can be set from config" do
        s3_uploader = S3Uploader.new(:url => "https://www.geocities.com")
        expect(s3_uploader.field_data_options[:url]).to eq "https://www.geocities.com"
      end

      it "defaults to <bucket>.s3.amazonaws.com/" do
        s3_uploader = S3Uploader.new(:bucket => "geocities-backup")
        expect(s3_uploader.field_data_options[:url]).to eq "//geocities-backup.s3.amazonaws.com/"
      end

      it "can be forced to use https" do
        s3_uploader = S3Uploader.new(:bucket => "geocities-backup", :ssl => true)
        expect(s3_uploader.field_data_options[:url]).to eq "https://geocities-backup.s3.amazonaws.com/"
      end

      it "can be forced to use http" do
        s3_uploader = S3Uploader.new(:bucket => "geocities-backup", :ssl => false)
        expect(s3_uploader.field_data_options[:url]).to eq "http://geocities-backup.s3.amazonaws.com/"
      end

      it "can be forced to use a specific region" do
        s3_uploader = S3Uploader.new(:bucket => "geocities-backup", :region => "s3-us-middle-3")
        expect(s3_uploader.field_data_options[:url]).to eq "//geocities-backup.s3-us-middle-3.amazonaws.com/"
      end
    end

    context '#field_options' do
      it 'removes s3_file_field specific options' do
        options = S3Uploader.new(:acl => true).field_options
        options.delete(:data)
        expect(options).to eq({})
      end

      it 'leaves non-s3_file_field specific options' do
        options = S3Uploader.new(:remote => true).field_options
        options.delete(:data)
        expect(options).to eq(:remote => true)
      end

      it 'leaves non-se_file_field specific data options' do
        options = S3Uploader.new(:data => {:remote => true }).field_options
        expect(options[:data]).to include(:remote => true)
      end
    end
  end
end
