# frozen_string_literal: true

require "test_helper"
require_relative "../lib/tormenta20/operations/operation_test_case"

class FeedbackTest < ActiveSupport::TestCase
  include OperationTestCase

  SUBMIT_MUTATION = <<~GQL
    mutation($title: String!, $description: String) {
      submitFeedback(title: $title, description: $description) {
        feedbackItem { id title description status upvotesCount upvoted }
        errors
      }
    }
  GQL

  TOGGLE_MUTATION = <<~GQL
    mutation($feedbackItemId: ID!) {
      toggleUpvote(feedbackItemId: $feedbackItemId) {
        feedbackItem { id upvotesCount upvoted }
        errors
      }
    }
  GQL

  ITEMS_QUERY = <<~GQL
    query {
      feedbackItems { id title status progress upvotesCount upvoted }
    }
  GQL

  setup do
    @user  = create_user
    @user2 = create_user(email: "other@test.com", username: "other_user")
  end

  # ── submitFeedback ────────────────────────────────────────────────────────

  test "submitFeedback creates a pending item" do
    result = exec_mutation(SUBMIT_MUTATION, { title: "Bug report", description: "Something broke" }, @user)
    item = result.dig("data", "submitFeedback", "feedbackItem")

    assert_equal "Bug report", item["title"]
    assert_equal "Something broke", item["description"]
    assert_equal "pending", item["status"]
    assert_equal 0, item["upvotesCount"]
    assert_equal [], result.dig("data", "submitFeedback", "errors")
  end

  test "submitFeedback requires authentication" do
    result = ArkheionSchema.execute(SUBMIT_MUTATION, variables: { title: "X" }, context: {})
    assert result["errors"].any? { |e| e["message"].include?("Not authenticated") }
  end

  test "submitFeedback returns errors for blank title" do
    result = exec_mutation(SUBMIT_MUTATION, { title: "" }, @user)
    errors = result.dig("data", "submitFeedback", "errors")
    assert_not_empty errors
  end

  # ── feedbackItems ─────────────────────────────────────────────────────────

  test "feedbackItems returns only visible items" do
    pending_item  = FeedbackItem.create!(title: "Pending",  user: @user)
    approved_item = FeedbackItem.create!(title: "Approved", user: @user, status: "approved")
    rejected_item = FeedbackItem.create!(title: "Rejected", user: @user, status: "rejected")

    result = ArkheionSchema.execute(ITEMS_QUERY, context: { current_user: @user })
    titles = result.dig("data", "feedbackItems").map { |i| i["title"] }

    assert_includes titles, approved_item.title
    assert_not_includes titles, pending_item.title
    assert_not_includes titles, rejected_item.title
  end

  test "feedbackItems marks upvoted correctly for current user" do
    item = FeedbackItem.create!(title: "Feature", user: @user, status: "approved")
    item.feedback_upvotes.create!(user: @user)

    result = ArkheionSchema.execute(ITEMS_QUERY, context: { current_user: @user })
    found  = result.dig("data", "feedbackItems").find { |i| i["id"] == item.id.to_s }

    assert found["upvoted"]
  end

  # ── toggleUpvote ──────────────────────────────────────────────────────────

  test "toggleUpvote adds upvote when not yet upvoted" do
    item = FeedbackItem.create!(title: "Feature", user: @user, status: "approved")

    result = exec_mutation(TOGGLE_MUTATION, { feedbackItemId: item.id }, @user)
    data   = result.dig("data", "toggleUpvote", "feedbackItem")

    assert_equal 1, data["upvotesCount"]
    assert data["upvoted"]
  end

  test "toggleUpvote removes upvote when already upvoted" do
    item = FeedbackItem.create!(title: "Feature", user: @user, status: "approved")
    item.feedback_upvotes.create!(user: @user)

    result = exec_mutation(TOGGLE_MUTATION, { feedbackItemId: item.id }, @user)
    data   = result.dig("data", "toggleUpvote", "feedbackItem")

    assert_equal 0, data["upvotesCount"]
    assert_not data["upvoted"]
  end

  test "toggleUpvote requires authentication" do
    item   = FeedbackItem.create!(title: "Feature", user: @user, status: "approved")
    result = ArkheionSchema.execute(TOGGLE_MUTATION, variables: { feedbackItemId: item.id }, context: {})
    assert result["errors"].any? { |e| e["message"].include?("Not authenticated") }
  end

  test "toggleUpvote returns error for non-visible item" do
    item   = FeedbackItem.create!(title: "Pending item", user: @user)
    result = exec_mutation(TOGGLE_MUTATION, { feedbackItemId: item.id }, @user)
    assert result["errors"].any? { |e| e["message"].include?("not found") }
  end

  private

  def exec_mutation(mutation, variables, user)
    ArkheionSchema.execute(mutation, variables: variables, context: { current_user: user })
  end

  def create_user(email: "testuser@test.com", username: "testuser")
    User.create!(
      email: email,
      username: username,
      password: "password123"
    )
  end
end
