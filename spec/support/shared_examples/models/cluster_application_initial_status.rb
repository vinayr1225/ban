# frozen_string_literal: true

shared_examples 'cluster application initial status specs' do |application_name|
  describe '#status' do
    let(:cluster) { create(:cluster, :provided_by_gcp) }

    subject { described_class.new(cluster: cluster) }

    context 'when application helm is scheduled' do
      before do
        create(:clusters_applications_helm, :scheduled, cluster: cluster)
      end

      it 'defaults to :not_installable' do
        expect(subject.status_name).to be(:not_installable)
      end
    end

    context 'when application is scheduled' do
      before do
        if application_name == :clusters_applications_knative
          allow_any_instance_of(Clusters::Cluster::KnativeServicesFinder)
            .to receive(:knative_detected)
            .and_return(Clusters::Cluster::KnativeServicesFinder::KNATIVE_STATES['uninstalled'])
        end

        create(:clusters_applications_helm, :installed, cluster: cluster)
      end

      it 'sets a default status' do
        expect(subject.status_name).to be(:installable)
      end
    end
  end
end
