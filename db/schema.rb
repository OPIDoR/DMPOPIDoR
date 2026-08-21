# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_20_144911) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "unaccent"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "mapping_type", ["json", "form"]

  create_table "annotations", id: :serial, force: :cascade do |t|
    t.integer "question_id"
    t.integer "org_id"
    t.text "text"
    t.integer "type", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "versionable_id", limit: 36
    t.index ["org_id"], name: "annotations_org_id_idx"
    t.index ["question_id"], name: "annotations_question_id_idx"
    t.index ["versionable_id"], name: "index_annotations_on_versionable_id"
  end


  create_table "answers", id: :serial, force: :cascade do |t|
    t.text "text"
    t.integer "plan_id"
    t.integer "user_id"
    t.integer "question_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "lock_version", default: 0
    t.boolean "is_common", default: false
    t.integer "research_output_id"
    t.index ["plan_id"], name: "answers_plan_id_idx"
    t.index ["question_id"], name: "answers_question_id_idx"
    t.index ["research_output_id"], name: "index_answers_on_research_output_id"
    t.index ["user_id"], name: "answers_user_id_idx"
  end


  create_table "answers_question_options", id: false, force: :cascade do |t|
    t.integer "answer_id", null: false
    t.integer "question_option_id", null: false
    t.index ["answer_id"], name: "answers_question_options_answer_id_idx"
    t.index ["question_option_id", "answer_id"], name: "idx_on_question_option_id_answer_id_86c1aca654", unique: true
    t.index ["question_option_id"], name: "answers_question_options_question_option_id_idx"
  end


  create_table "api_client_roles", force: :cascade do |t|
    t.integer "access", default: 0, null: false
    t.bigint "api_client_id", null: false
    t.bigint "plan_id", null: false
    t.bigint "research_output_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["api_client_id"], name: "index_api_client_roles_on_api_client_id"
    t.index ["plan_id"], name: "index_api_client_roles_on_plan_id"
    t.index ["research_output_id"], name: "index_api_client_roles_on_research_output_id"
  end


  create_table "api_clients", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "homepage"
    t.string "contact_name"
    t.string "contact_email", null: false
    t.string "client_id", null: false
    t.string "client_secret", null: false
    t.datetime "last_access", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "org_id"
    t.boolean "send_notification", default: false, null: false
    t.index ["name"], name: "index_api_clients_on_name"
  end


  create_table "comment_read_marks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "answer_id", null: false
    t.datetime "last_read_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["answer_id"], name: "index_comment_read_marks_on_answer_id"
    t.index ["user_id", "answer_id"], name: "index_comment_read_marks_on_user_id_and_answer_id", unique: true
    t.index ["user_id"], name: "index_comment_read_marks_on_user_id"
  end


  create_table "conditions", id: :serial, force: :cascade do |t|
    t.integer "question_id"
    t.text "option_list"
    t.integer "action_type"
    t.integer "number"
    t.text "remove_data"
    t.text "webhook_data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["question_id"], name: "index_conditions_on_question_id"
  end


  create_table "contributors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.integer "roles", null: false
    t.integer "org_id"
    t.integer "plan_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["email"], name: "index_contributors_on_email"
    t.index ["org_id"], name: "index_contributors_on_org_id"
    t.index ["plan_id"], name: "index_contributors_on_plan_id"
    t.index ["roles"], name: "index_contributors_on_roles"
  end


  create_table "departments", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "org_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["org_id"], name: "index_departments_on_org_id"
  end


  create_table "exported_plans", id: :serial, force: :cascade do |t|
    t.integer "plan_id"
    t.integer "user_id"
    t.string "format"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "phase_id"
  end


  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
  end


  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end


  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end


  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end


  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at_only", where: "(finished_at IS NOT NULL)"
    t.index ["job_class"], name: "index_good_jobs_on_job_class"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end


  create_table "guidance_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "published", default: false, null: false
    t.string "description"
    t.integer "language_id", default: 0
    t.string "topics", default: ["generic"], null: false, array: true
    t.string "data_types", default: ["dataset"], null: false, array: true
    t.boolean "is_default", default: false, null: false
    t.index ["org_id"], name: "guidance_groups_org_id_idx"
  end


  create_table "guidance_groups_research_outputs", id: false, force: :cascade do |t|
    t.bigint "research_output_id", null: false
    t.bigint "guidance_group_id", null: false
  end


  create_table "guidances", id: :serial, force: :cascade do |t|
    t.text "text"
    t.integer "guidance_group_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "published"
    t.string "locale", default: "fr-FR"
    t.index ["guidance_group_id"], name: "guidances_guidance_group_id_idx"
  end


  create_table "guided_tours", force: :cascade do |t|
    t.bigint "user_id"
    t.string "tour"
    t.boolean "ended", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_guided_tours_on_user_id"
  end


  create_table "identifier_schemes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "active"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "logo_url"
    t.string "identifier_prefix"
    t.integer "context"
  end


  create_table "identifiers", id: :serial, force: :cascade do |t|
    t.string "value", null: false
    t.text "attrs"
    t.integer "identifier_scheme_id"
    t.integer "identifiable_id"
    t.string "identifiable_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["identifiable_type", "identifiable_id"], name: "index_identifiers_on_identifiable_type_and_identifiable_id"
    t.index ["identifier_scheme_id", "identifiable_id", "identifiable_type"], name: "index_identifiers_on_scheme_and_type_and_id"
    t.index ["identifier_scheme_id", "value"], name: "index_identifiers_on_identifier_scheme_id_and_value"
  end


  create_table "json_plans", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.string "dmp_id"
    t.string "research_outputs_uuids", default: [], array: true
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data"], name: "idx_json_plans_data_gin", using: :gin
    t.index ["dmp_id"], name: "index_json_plans_on_dmp_id"
    t.index ["plan_id"], name: "index_json_plans_on_plan_id"
  end


  create_table "languages", id: :serial, force: :cascade do |t|
    t.string "abbreviation"
    t.string "description"
    t.string "name"
    t.boolean "default_language"
  end


  create_table "madmp_fragments", id: :serial, force: :cascade do |t|
    t.json "data", default: {}
    t.integer "answer_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "classname"
    t.integer "dmp_id"
    t.integer "parent_id"
    t.integer "madmp_schema_id"
    t.json "additional_info"
    t.index "((data ->> 'plan_id'::text))", name: "madmp_fragments_plan_id_idx"
    t.index "((data ->> 'research_output_id'::text))", name: "madmp_fragments_research_output_id_idx"
    t.index ["answer_id"], name: "index_madmp_fragments_on_answer_id"
    t.index ["dmp_id"], name: "madmp_fragments_dmp_id_idx"
    t.index ["madmp_schema_id"], name: "index_madmp_fragments_on_madmp_schema_id"
    t.index ["parent_id"], name: "madmp_fragments_parent_id_idx"
  end


  create_table "madmp_schemas", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "name"
    t.integer "version"
    t.json "schema", default: {}
    t.integer "org_id"
    t.string "classname"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "api_client_id"
    t.string "data_type", default: "dataset", null: false
    t.string "topics", default: ["generic"], null: false, array: true
    t.index ["api_client_id"], name: "index_madmp_schemas_on_api_client_id"
    t.index ["org_id"], name: "index_madmp_schemas_on_org_id"
  end


  create_table "notes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "text"
    t.boolean "archived", default: false, null: false
    t.integer "answer_id"
    t.integer "archived_by"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["answer_id"], name: "notes_answer_id_idx"
    t.index ["user_id"], name: "notes_user_id_idx"
  end


  create_table "notification_acknowledgements", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "notification_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["notification_id"], name: "notification_acknowledgements_notification_id_idx"
    t.index ["user_id"], name: "notification_acknowledgements_user_id_idx"
  end


  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "notification_type"
    t.string "title"
    t.integer "level"
    t.text "body"
    t.boolean "dismissable"
    t.date "starts_at"
    t.date "expires_at"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "enabled", default: true
  end


  create_table "options", id: :serial, force: :cascade do |t|
    t.integer "question_id"
    t.string "text"
    t.integer "number"
    t.boolean "is_default"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end


  create_table "org_token_permissions", id: :serial, force: :cascade do |t|
    t.integer "org_id"
    t.integer "token_permission_type_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["org_id"], name: "org_token_permissions_org_id_idx"
    t.index ["token_permission_type_id"], name: "org_token_permissions_token_permission_type_id_idx"
  end


  create_table "orgs", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.string "target_url"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "is_other", default: false, null: false
    t.text "banner_text"
    t.integer "language_id"
    t.string "logo_uid"
    t.string "logo_name"
    t.string "contact_email"
    t.integer "org_type", default: 0, null: false
    t.text "links"
    t.string "contact_name"
    t.boolean "feedback_enabled", default: false
    t.text "feedback_msg"
    t.boolean "active", default: true
    t.boolean "managed", default: false, null: false
    t.string "helpdesk_email"
    t.index ["language_id"], name: "orgs_language_id_idx"
  end


  create_table "perms", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end


  create_table "phases", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "number"
    t.integer "template_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "modifiable"
    t.string "versionable_id", limit: 36
    t.index ["template_id"], name: "phases_template_id_idx"
    t.index ["versionable_id"], name: "index_phases_on_versionable_id"
  end


  create_table "plans", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "template_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "identifier"
    t.text "description"
    t.integer "visibility", default: 3, null: false
    t.boolean "feedback_requested", default: false
    t.boolean "complete", default: false
    t.integer "feedback_requestor_id"
    t.datetime "feedback_request_date", precision: nil
    t.integer "org_id"
    t.integer "funder_id"
    t.integer "grant_id"
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.bigint "research_domain_id"
    t.boolean "ethical_issues"
    t.text "ethical_issues_description"
    t.string "ethical_issues_report"
    t.integer "funding_status"
    t.integer "context", default: 0, null: false
    t.index ["funder_id"], name: "index_plans_on_funder_id"
    t.index ["grant_id"], name: "index_plans_on_grant_id"
    t.index ["org_id"], name: "index_plans_on_org_id"
    t.index ["research_domain_id"], name: "index_plans_on_research_domain_id"
    t.index ["template_id"], name: "plans_template_id_idx"
  end


  create_table "plans_guidance_groups", id: :serial, force: :cascade do |t|
    t.integer "guidance_group_id"
    t.integer "plan_id"
    t.index ["guidance_group_id"], name: "plans_guidance_groups_guidance_group_id_idx"
    t.index ["plan_id"], name: "plans_guidance_groups_plan_id_idx"
  end


  create_table "prefs", id: :serial, force: :cascade do |t|
    t.text "settings"
    t.integer "user_id"
  end


  create_table "question_formats", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "option_based", default: false
    t.integer "formattype", default: 0
    t.boolean "structured", default: false, null: false
  end


  create_table "question_options", id: :serial, force: :cascade do |t|
    t.integer "question_id"
    t.string "text"
    t.integer "number"
    t.boolean "is_default"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "versionable_id", limit: 36
    t.index ["question_id"], name: "question_options_question_id_idx"
    t.index ["versionable_id"], name: "index_question_options_on_versionable_id"
  end


  create_table "questions", id: :serial, force: :cascade do |t|
    t.text "text"
    t.text "default_value"
    t.integer "number"
    t.integer "section_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "question_format_id"
    t.boolean "option_comment_display", default: true
    t.boolean "modifiable"
    t.string "versionable_id", limit: 36
    t.integer "madmp_schema_id"
    t.index ["madmp_schema_id"], name: "index_questions_on_madmp_schema_id"
    t.index ["question_format_id"], name: "questions_question_format_id_idx"
    t.index ["section_id"], name: "questions_section_id_idx"
    t.index ["versionable_id"], name: "index_questions_on_versionable_id"
  end


  create_table "questions_themes", id: false, force: :cascade do |t|
    t.integer "question_id", null: false
    t.integer "theme_id", null: false
    t.index ["question_id"], name: "questions_themes_question_id_idx"
    t.index ["theme_id"], name: "questions_themes_theme_id_idx"
  end


  create_table "registries", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "uri"
    t.integer "version"
    t.integer "org_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "data_types", default: ["dataset"], null: false, array: true
    t.string "category"
    t.json "values"
    t.string "topics", default: ["generic"], null: false, array: true
    t.index ["org_id"], name: "index_registries_on_org_id"
  end


  create_table "research_outputs", id: :serial, force: :cascade do |t|
    t.string "abbreviation"
    t.integer "display_order"
    t.boolean "is_default", default: false
    t.integer "plan_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "pid"
    t.integer "output_type", default: 3, null: false
    t.string "output_type_description"
    t.string "title"
    t.text "description"
    t.string "uuid"
    t.string "topic", default: "generic", null: false
    t.index ["plan_id"], name: "index_research_outputs_on_plan_id"
  end


  create_table "roles", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "plan_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "access", default: 0, null: false
    t.boolean "active", default: false
    t.index ["plan_id"], name: "roles_plan_id_idx"
    t.index ["user_id"], name: "roles_user_id_idx"
  end


  create_table "sections", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "number"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "phase_id"
    t.boolean "modifiable"
    t.string "versionable_id", limit: 36
    t.index ["phase_id"], name: "sections_phase_id_idx"
    t.index ["versionable_id"], name: "index_sections_on_versionable_id"
  end


  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", limit: 64, null: false
    t.text "data"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end


  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "target_id", null: false
    t.string "target_type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["target_type", "target_id", "var"], name: "settings_target_type_target_id_var_key", unique: true
  end


  create_table "stats", id: :serial, force: :cascade do |t|
    t.bigint "count", default: 0
    t.date "date", null: false
    t.string "type", null: false
    t.integer "org_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "details"
    t.boolean "filtered", default: false
  end


  create_table "templates", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "published"
    t.integer "org_id"
    t.string "locale"
    t.boolean "is_default"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "version"
    t.integer "visibility"
    t.integer "customization_of"
    t.integer "family_id"
    t.boolean "archived"
    t.text "links"
    t.integer "type", default: 0, null: false
    t.integer "context", default: 0, null: false
    t.boolean "is_recommended", default: false
    t.string "data_type", default: "dataset", null: false
    t.string "contexts", default: ["research_project"], null: false, array: true
    t.index ["customization_of", "version", "org_id"], name: "templates_customization_of_version_org_id_key", unique: true
    t.index ["family_id", "version"], name: "templates_family_id_version_key", unique: true
    t.index ["org_id"], name: "templates_org_id_idx"
  end


  create_table "themes", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug"
    t.json "translations", default: {}
    t.integer "number"
    t.string "data_type", default: "dataset", null: false
  end


  create_table "themes_in_guidance", id: false, force: :cascade do |t|
    t.integer "theme_id"
    t.integer "guidance_id"
    t.index ["guidance_id"], name: "themes_in_guidance_guidance_id_idx"
    t.index ["theme_id"], name: "themes_in_guidance_theme_id_idx"
  end


  create_table "token_permission_types", id: :serial, force: :cascade do |t|
    t.string "token_type"
    t.text "text_description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end


  create_table "user_org_roles", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "organisation_id"
    t.integer "user_role_type_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end


  create_table "users", id: :serial, force: :cascade do |t|
    t.string "firstname"
    t.string "surname"
    t.string "email", limit: 80, default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "encrypted_password", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.string "other_organisation"
    t.boolean "dmponline3"
    t.boolean "accept_terms"
    t.integer "org_id"
    t.string "api_token"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.integer "language_id"
    t.string "recovery_email"
    t.boolean "active", default: true
    t.integer "department_id"
    t.datetime "last_api_access", precision: nil
    t.index ["email"], name: "users_email_key", unique: true
    t.index ["language_id"], name: "users_language_id_idx"
    t.index ["org_id"], name: "users_org_id_idx"
  end


  create_table "users_perms", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "perm_id"
    t.index ["perm_id"], name: "users_perms_perm_id_idx"
    t.index ["user_id"], name: "users_perms_user_id_idx"
  end


  add_foreign_key "annotations", "orgs", deferrable: :deferred
  add_foreign_key "annotations", "questions", deferrable: :deferred
  add_foreign_key "answers", "plans", deferrable: :deferred
  add_foreign_key "answers", "questions", deferrable: :deferred
  add_foreign_key "answers", "research_outputs"
  add_foreign_key "answers", "users", deferrable: :deferred
  add_foreign_key "answers_question_options", "answers", deferrable: :deferred
  add_foreign_key "answers_question_options", "question_options", deferrable: :deferred
  add_foreign_key "comment_read_marks", "answers"
  add_foreign_key "comment_read_marks", "users"
  add_foreign_key "conditions", "questions"
  add_foreign_key "guidance_groups", "orgs", deferrable: :deferred
  add_foreign_key "guidances", "guidance_groups", deferrable: :deferred
  add_foreign_key "guided_tours", "users"
  add_foreign_key "madmp_fragments", "answers"
  add_foreign_key "madmp_fragments", "madmp_schemas"
  add_foreign_key "madmp_schemas", "api_clients"
  add_foreign_key "madmp_schemas", "orgs"
  add_foreign_key "notes", "answers", deferrable: :deferred
  add_foreign_key "notes", "users", deferrable: :deferred
  add_foreign_key "notification_acknowledgements", "notifications", deferrable: :deferred
  add_foreign_key "notification_acknowledgements", "users", deferrable: :deferred
  add_foreign_key "org_token_permissions", "orgs", deferrable: :deferred
  add_foreign_key "org_token_permissions", "token_permission_types", deferrable: :deferred
  add_foreign_key "orgs", "languages", deferrable: :deferred
  add_foreign_key "phases", "templates", deferrable: :deferred
  add_foreign_key "plans", "orgs"
  add_foreign_key "plans", "templates", deferrable: :deferred
  add_foreign_key "plans_guidance_groups", "guidance_groups", deferrable: :deferred
  add_foreign_key "plans_guidance_groups", "plans", deferrable: :deferred
  add_foreign_key "question_options", "questions", deferrable: :deferred
  add_foreign_key "questions", "madmp_schemas"
  add_foreign_key "questions", "question_formats", deferrable: :deferred
  add_foreign_key "questions", "sections", deferrable: :deferred
  add_foreign_key "questions_themes", "questions", deferrable: :deferred
  add_foreign_key "questions_themes", "themes", deferrable: :deferred
  add_foreign_key "registries", "orgs"
  add_foreign_key "research_outputs", "plans"
  add_foreign_key "roles", "plans", deferrable: :deferred
  add_foreign_key "roles", "users", deferrable: :deferred
  add_foreign_key "sections", "phases", deferrable: :deferred
  add_foreign_key "templates", "orgs", deferrable: :deferred
  add_foreign_key "themes_in_guidance", "guidances", deferrable: :deferred
  add_foreign_key "themes_in_guidance", "themes", deferrable: :deferred
  add_foreign_key "users", "departments"
  add_foreign_key "users", "languages", deferrable: :deferred
  add_foreign_key "users", "orgs", deferrable: :deferred
  add_foreign_key "users_perms", "perms", deferrable: :deferred
  add_foreign_key "users_perms", "users", deferrable: :deferred
end
