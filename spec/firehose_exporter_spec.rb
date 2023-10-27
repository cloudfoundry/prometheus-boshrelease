require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'

describe 'firehose_exporter job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
  let(:job) { release.job('firehose_exporter') }

  describe 'config/bpm.yml template' do
    let(:template) { job.template('config/bpm.yml') }
    let(:rendered_template) { template.render(properties) }
    let(:properties) do
      {
        'firehose_exporter' => {
          'metrics' => {
            'environment' => 'test'
          },
          'logging' => {
            'url' => 'http://api.yoursystemdomain.here.com'
          },
          'retro_compat' => {
            'disable' => true
          }
        }
      }
    end

    it 'renders with retro_compat disabled' do
      expect(rendered_template).to include('FIREHOSE_EXPORTER_RETRO_COMPAT_DISABLE: true')
    end
  end
end
