# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrgAdmin::GuidanceGroupsController, type: :controller do
  before(:each) do
    @org = create(:org, managed: true)
    @user = create(:user, :org_admin, org: @org)
    # The Org factory auto-creates a guidance_group
    @guidance_group = GuidanceGroup.create_org_default(@org)

    @controller = described_class.new
    sign_in(@user)
  end

  it 'GET /org_admin/guidance_groups/new (:new)' do
    get :new, params: { id: @org.id }
    expect(response).to render_template('org_admin/guidance_groups/new')
    gg = assigns(:guidance_group)
    expect(gg.new_record?).to eql(true)
    expect(gg.org_id).to eql(@org.id)
  end

  it 'GET /org_admin/guidance_groups/:id/admin_edit (:edit)' do
    get :edit, params: { id: @guidance_group.id }
    expect(response).to render_template('org_admin/guidance_groups/edit')
    expect(assigns(:guidance_group)).to eql(@guidance_group)
  end

  describe 'POST /org_admin/guidance_groups (:create)' do
    it 'succeeds' do
      args = { name: Faker::Lorem.sentence, published: Faker::Boolean.boolean, org_id: @org.id }
      post :create, params: { id: @org.id, guidance_group: args }
      expect(response).to render_template('org_admin/guidance_groups/edit')
      expect(flash[:notice].present?).to eql(true)
      gg = assigns(:guidance_group)
      expect(gg.id).not_to eql(@guidance_group.id)
      expect(gg.name).to eql(args[:name])
      expect(gg.published).to eql(args[:published])
      expect(gg.org_id).to eql(args[:org_id])
    end
    it 'fails' do
      args = { name: nil }
      post :create, params: { id: @org.id, guidance_group: args }
      expect(response).to render_template('org_admin/guidance_groups/new')
      expect(flash[:alert].present?).to eql(true)
    end
  end

  describe 'PUT /org_admin/guidance_groups/:id (:update)' do
    it 'succeeds' do
      args = { name: Faker::Lorem.sentence, published: Faker::Boolean.boolean }
      put :update, params: { id: @guidance_group.id, guidance_group: args }
      expect(response).to render_template('org_admin/guidance_groups/edit')
      expect(flash[:notice].present?).to eql(true)
      gg = assigns(:guidance_group)
      expect(gg.id).to eql(@guidance_group.id)
      expect(gg.name).to eql(args[:name])
      expect(gg.published).to eql(args[:published])
      expect(gg.org_id).to eql(@org.id)
    end
    it 'fails' do
      args = { name: nil }
      put :update, params: { id: @guidance_group.id, guidance_group: args }
      expect(response).to render_template('org_admin/guidance_groups/edit')
      expect(flash[:alert].present?).to eql(true)
    end
  end

  describe 'PUT /org_admin/guidance_groups/:id/publish (:publish)' do
    before(:each) do
      @guidance_group.update(published: false)
    end

    it 'succeeds' do
      args = { published: true }
      put :publish, params: { id: @guidance_group.id, guidance_group: args }
      expect(response).to redirect_to(org_admin_guidances_path)
      expect(flash[:notice].present?).to eql(true)
      expect(@guidance_group.reload.published?).to eql(true)
    end
    it 'fails' do
      GuidanceGroup.any_instance.stubs(:update).returns(false)
      args = { published: false }
      put :publish, params: { id: @guidance_group.id, guidance_group: args }
      expect(response).to redirect_to(org_admin_guidances_path)
      expect(flash[:alert].present?).to eql(true)
      expect(@guidance_group.reload.published?).to eql(false)
    end
  end

  describe 'PUT /org_admin/guidance_groups/:id/_unpublish (:unpublish)' do
    before(:each) do
      @guidance_group.update(published: true)
    end

    it 'succeeds' do
      args = { published: false }
      put :unpublish, params: { id: @guidance_group.id, guidance_group: args }
      expect(response).to redirect_to(org_admin_guidances_path)
      expect(flash[:notice].present?).to eql(true)
      expect(@guidance_group.reload.published?).to eql(false)
    end
    it 'fails' do
      GuidanceGroup.any_instance.stubs(:update).returns(false)
      args = { published: true }
      put :unpublish, params: { id: @guidance_group.id, guidance_group: args }
      expect(response).to redirect_to(org_admin_guidances_path)
      expect(flash[:alert].present?).to eql(true)
      expect(@guidance_group.reload.published?).to eql(true)
    end
  end

  describe 'DELETE /org_admin/guidance_groups/:id (:destroy)' do
    it 'succeeds' do
      delete :destroy, params: { id: @guidance_group.id }
      expect(response).to redirect_to(org_admin_guidances_path)
      expect(flash[:notice].present?).to eql(true)
      expect(GuidanceGroup.where(id: @guidance_group.id).any?).to eql(false)
    end
    it 'fails' do
      GuidanceGroup.any_instance.stubs(:destroy).returns(false)
      delete :destroy, params: { id: @guidance_group.id }
      expect(response).to redirect_to(org_admin_guidances_path)
      expect(flash[:alert].present?).to eql(true)
    end
  end
end
