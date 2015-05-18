require 'spec_helper'

describe Submission do

  describe '#results_visible?' do
    let(:gobstones) { create(:language, visible_success_output: true)  }
    let(:gobstones_exercise) { create(:exercise, language: gobstones) }

    let(:failed_submission) { create(:submission, status: :failed) }
    let(:passed_submission) { create(:submission, status: :passed, expectation_results: []) }
    let(:passed_submission_with_visible_output_language) { create(:submission, status: :passed, exercise: gobstones_exercise) }

    it { expect(passed_submission.results_visible?).to be false }
    it { expect(failed_submission.results_visible?).to be true }
    it { expect(passed_submission_with_visible_output_language.results_visible?).to be true }
  end
  describe '#run_update!' do
    let(:submission) { create(:submission) }
    context 'when run passes' do
      before { submission.run_update! { {result: 'ok', status: :passed} } }
      it { expect(submission.status).to eq('passed') }
      it { expect(submission.result).to eq('ok') }
    end
    context 'when run fails' do
      before { submission.run_update! { {result: 'ups', status: :failed} } }
      it { expect(submission.status).to eq('failed') }
      it { expect(submission.result).to eq('ups') }
    end
    context 'when run aborts' do
      before do
        begin
          submission.run_update! { raise 'ouch' }
        rescue
        end
      end
      it { expect(submission.status).to eq('failed') }
      it { expect(submission.result).to eq('ouch') }
    end
  end

  describe '#update_submissions_count!' do
    let(:exercise) { create(:exercise) }
    let(:user) { create(:user) }

    before do
      exercise.submissions.create!(submitter: user)
      exercise.submissions.create!(submitter: user)
      exercise.submissions.create!(submitter: user)
    end

    it { expect(exercise.reload.submissions_count).to eq(3) }
  end

  describe 'eligible_for_run?' do
    let(:exercise) { create(:exercise) }
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    context 'when there is only one submission' do
      let(:submission) { exercise.submissions.create!(submitter: user) }

      it { expect(submission.eligible_for_run?).to be true  }
    end

    context 'when there are many submissions' do
      let!(:submission) { exercise.submissions.create!(submitter: user) }
      let!(:other_submission) { exercise.submissions.create!(submitter: user) }
      let!(:submission_for_other_user) { exercise.submissions.create!(submitter: other_user) }

      it { expect(submission.eligible_for_run?).to be false }
      it { expect(other_submission.eligible_for_run?).to be true  }
      it { expect(submission_for_other_user.eligible_for_run?).to be true  }
    end


  end
end
