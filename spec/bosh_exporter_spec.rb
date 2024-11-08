require 'rspec'
require 'json'
require 'yaml'
require 'bosh/template/test'

describe 'bosh_exporter job' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
  let(:job) { release.job('bosh_exporter') }

  describe 'bin/bosh_exporter_ctl template' do
    let(:template) { job.template('bin/bosh_exporter_ctl') }
    let(:rendered_template) { template.render(properties) }
    let(:properties) do
      {
        'bosh_exporter' => {
          'metrics' => {
            'environment' => 'test'
          },
          'bosh' => {
            'url' => 'http://yourboshurl'
          }
        }
      }
    end

    it 'renders with default values' do
      expect(rendered_template).to include('--bosh.url="http://yourboshurl"')
      expect(rendered_template).to include('--metrics.environment="test"')
      expect(rendered_template).to include('--sd.filename="${STORE_DIR}/bosh_target_groups.json"')
      expect(rendered_template).to include('--web.listen-address=":9190"')
    end
  end
end
