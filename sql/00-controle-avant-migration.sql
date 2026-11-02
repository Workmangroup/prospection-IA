-- Lecture seule. Choisir la base WORKMAN existante dans phpMyAdmin.
SELECT DATABASE() AS base_selectionnee;
-- Tables historiques 1.9 requises : résultat vide attendu.
SELECT e.table_name AS table_manquante FROM (
SELECT 'wm_admin_settings' AS table_name
UNION ALL
SELECT 'wm_audit' AS table_name
UNION ALL
SELECT 'wm_commodity_observations' AS table_name
UNION ALL
SELECT 'wm_company_memberships' AS table_name
UNION ALL
SELECT 'wm_company_profiles' AS table_name
UNION ALL
SELECT 'wm_company_settings' AS table_name
UNION ALL
SELECT 'wm_connections' AS table_name
UNION ALL
SELECT 'wm_contact_options' AS table_name
UNION ALL
SELECT 'wm_contact_validation' AS table_name
UNION ALL
SELECT 'wm_discovery_candidates' AS table_name
UNION ALL
SELECT 'wm_discovery_jobs' AS table_name
UNION ALL
SELECT 'wm_drafts' AS table_name
UNION ALL
SELECT 'wm_email_checks' AS table_name
UNION ALL
SELECT 'wm_expenses' AS table_name
UNION ALL
SELECT 'wm_inbox' AS table_name
UNION ALL
SELECT 'wm_inbox_sync' AS table_name
UNION ALL
SELECT 'wm_install' AS table_name
UNION ALL
SELECT 'wm_interactions' AS table_name
UNION ALL
SELECT 'wm_lead_tracking' AS table_name
UNION ALL
SELECT 'wm_leads' AS table_name
UNION ALL
SELECT 'wm_limits' AS table_name
UNION ALL
SELECT 'wm_merge_log' AS table_name
UNION ALL
SELECT 'wm_mfa' AS table_name
UNION ALL
SELECT 'wm_opportunities' AS table_name
UNION ALL
SELECT 'wm_organizations' AS table_name
UNION ALL
SELECT 'wm_products' AS table_name
UNION ALL
SELECT 'wm_quote_counters' AS table_name
UNION ALL
SELECT 'wm_quote_items' AS table_name
UNION ALL
SELECT 'wm_quotes' AS table_name
UNION ALL
SELECT 'wm_search_results' AS table_name
UNION ALL
SELECT 'wm_searches' AS table_name
UNION ALL
SELECT 'wm_sourcing_access' AS table_name
UNION ALL
SELECT 'wm_sourcing_jobs' AS table_name
UNION ALL
SELECT 'wm_sourcing_purchases' AS table_name
UNION ALL
SELECT 'wm_sourcing_record_history' AS table_name
UNION ALL
SELECT 'wm_sourcing_requirements' AS table_name
UNION ALL
SELECT 'wm_supplier_assessments' AS table_name
UNION ALL
SELECT 'wm_supplier_offers' AS table_name
UNION ALL
SELECT 'wm_supplier_rfq' AS table_name
UNION ALL
SELECT 'wm_suppliers' AS table_name
UNION ALL
SELECT 'wm_suppressions' AS table_name
UNION ALL
SELECT 'wm_task_actions' AS table_name
UNION ALL
SELECT 'wm_used_recovery' AS table_name
UNION ALL
SELECT 'wm_users' AS table_name) e LEFT JOIN information_schema.tables t ON t.table_schema=DATABASE() AND t.table_name=e.table_name WHERE t.table_name IS NULL;
-- Colonnes manquantes des tables 09 à 12 SI ces tables existent déjà.
-- Résultat vide attendu. Les tables absentes sont créées par leur migration.
SELECT e.table_name,e.column_name AS colonne_manquante FROM (
SELECT 'wm_b2b_accounts' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_b2b_accounts' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_b2b_accounts' AS table_name,'lead_id' AS column_name
UNION ALL
SELECT 'wm_b2b_accounts' AS table_name,'login_code' AS column_name
UNION ALL
SELECT 'wm_b2b_accounts' AS table_name,'email' AS column_name
UNION ALL
SELECT 'wm_b2b_accounts' AS table_name,'full_name' AS column_name
UNION ALL
SELECT 'wm_b2b_accounts' AS table_name,'password_hash' AS column_name
UNION ALL
SELECT 'wm_b2b_accounts' AS table_name,'active' AS column_name
UNION ALL
SELECT 'wm_b2b_accounts' AS table_name,'must_change' AS column_name
UNION ALL
SELECT 'wm_b2b_accounts' AS table_name,'auth_version' AS column_name
UNION ALL
SELECT 'wm_b2b_accounts' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_b2b_bat_decisions' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_b2b_bat_decisions' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_b2b_bat_decisions' AS table_name,'lead_id' AS column_name
UNION ALL
SELECT 'wm_b2b_bat_decisions' AS table_name,'document_id' AS column_name
UNION ALL
SELECT 'wm_b2b_bat_decisions' AS table_name,'account_id' AS column_name
UNION ALL
SELECT 'wm_b2b_bat_decisions' AS table_name,'decision' AS column_name
UNION ALL
SELECT 'wm_b2b_bat_decisions' AS table_name,'sha256' AS column_name
UNION ALL
SELECT 'wm_b2b_bat_decisions' AS table_name,'note' AS column_name
UNION ALL
SELECT 'wm_b2b_bat_decisions' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'lead_id' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'order_id' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'kind' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'title' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'file_name' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'pdf_base64' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'sha256' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'visible' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'bat_status' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'replaces_id' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'created_by' AS column_name
UNION ALL
SELECT 'wm_b2b_documents' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_b2b_messages' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_b2b_messages' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_b2b_messages' AS table_name,'lead_id' AS column_name
UNION ALL
SELECT 'wm_b2b_messages' AS table_name,'thread_id' AS column_name
UNION ALL
SELECT 'wm_b2b_messages' AS table_name,'account_id' AS column_name
UNION ALL
SELECT 'wm_b2b_messages' AS table_name,'staff_id' AS column_name
UNION ALL
SELECT 'wm_b2b_messages' AS table_name,'message' AS column_name
UNION ALL
SELECT 'wm_b2b_messages' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'lead_id' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'reference' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'title' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'status' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'production_note' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'shipment_note' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'carrier' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'tracking_ref' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'estimated_delivery' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_b2b_orders' AS table_name,'updated_at' AS column_name
UNION ALL
SELECT 'wm_b2b_quotes' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_b2b_quotes' AS table_name,'lead_id' AS column_name
UNION ALL
SELECT 'wm_b2b_quotes' AS table_name,'quote_id' AS column_name
UNION ALL
SELECT 'wm_b2b_quotes' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_b2b_threads' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_b2b_threads' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_b2b_threads' AS table_name,'lead_id' AS column_name
UNION ALL
SELECT 'wm_b2b_threads' AS table_name,'kind' AS column_name
UNION ALL
SELECT 'wm_b2b_threads' AS table_name,'subject' AS column_name
UNION ALL
SELECT 'wm_b2b_threads' AS table_name,'status' AS column_name
UNION ALL
SELECT 'wm_b2b_threads' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_b2b_threads' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_crm_contacts' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_crm_contacts' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_crm_contacts' AS table_name,'lead_id' AS column_name
UNION ALL
SELECT 'wm_crm_contacts' AS table_name,'full_name' AS column_name
UNION ALL
SELECT 'wm_crm_contacts' AS table_name,'role_text' AS column_name
UNION ALL
SELECT 'wm_crm_contacts' AS table_name,'email' AS column_name
UNION ALL
SELECT 'wm_crm_contacts' AS table_name,'phone' AS column_name
UNION ALL
SELECT 'wm_crm_contacts' AS table_name,'notes' AS column_name
UNION ALL
SELECT 'wm_crm_contacts' AS table_name,'active' AS column_name
UNION ALL
SELECT 'wm_crm_contacts' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_crm_contacts' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_crm_contacts' AS table_name,'updated_at' AS column_name
UNION ALL
SELECT 'wm_pilot_access' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_pilot_access' AS table_name,'user_id' AS column_name
UNION ALL
SELECT 'wm_pilot_access' AS table_name,'scope' AS column_name
UNION ALL
SELECT 'wm_pilot_access' AS table_name,'granted_by' AS column_name
UNION ALL
SELECT 'wm_pilot_access' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'alert_key' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'scope' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'entity_type' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'entity_id' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'title' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'next_action' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'owner_id' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'due_date' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'status' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'created_by' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_pilot_actions' AS table_name,'updated_at' AS column_name
UNION ALL
SELECT 'wm_pilot_client_meta' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_pilot_client_meta' AS table_name,'lead_id' AS column_name
UNION ALL
SELECT 'wm_pilot_client_meta' AS table_name,'channel' AS column_name
UNION ALL
SELECT 'wm_pilot_client_meta' AS table_name,'latitude' AS column_name
UNION ALL
SELECT 'wm_pilot_client_meta' AS table_name,'longitude' AS column_name
UNION ALL
SELECT 'wm_pilot_client_meta' AS table_name,'source_note' AS column_name
UNION ALL
SELECT 'wm_pilot_client_meta' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_pilot_client_meta' AS table_name,'updated_at' AS column_name
UNION ALL
SELECT 'wm_pilot_hr_snapshots' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_pilot_hr_snapshots' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_pilot_hr_snapshots' AS table_name,'snapshot_date' AS column_name
UNION ALL
SELECT 'wm_pilot_hr_snapshots' AS table_name,'department' AS column_name
UNION ALL
SELECT 'wm_pilot_hr_snapshots' AS table_name,'staff_count' AS column_name
UNION ALL
SELECT 'wm_pilot_hr_snapshots' AS table_name,'absent_count' AS column_name
UNION ALL
SELECT 'wm_pilot_hr_snapshots' AS table_name,'planned_hours' AS column_name
UNION ALL
SELECT 'wm_pilot_hr_snapshots' AS table_name,'worked_hours' AS column_name
UNION ALL
SELECT 'wm_pilot_hr_snapshots' AS table_name,'overtime_hours' AS column_name
UNION ALL
SELECT 'wm_pilot_hr_snapshots' AS table_name,'source_note' AS column_name
UNION ALL
SELECT 'wm_pilot_hr_snapshots' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_pilot_hr_snapshots' AS table_name,'updated_at' AS column_name
UNION ALL
SELECT 'wm_pilot_opportunity_meta' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_pilot_opportunity_meta' AS table_name,'opportunity_id' AS column_name
UNION ALL
SELECT 'wm_pilot_opportunity_meta' AS table_name,'probability_bps' AS column_name
UNION ALL
SELECT 'wm_pilot_opportunity_meta' AS table_name,'closed_date' AS column_name
UNION ALL
SELECT 'wm_pilot_opportunity_meta' AS table_name,'source_note' AS column_name
UNION ALL
SELECT 'wm_pilot_opportunity_meta' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_pilot_opportunity_meta' AS table_name,'updated_at' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'lead_id' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'reference' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'currency' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'total_amount' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'paid_amount' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'invoice_date' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'due_date' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'source_note' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'active' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_pilot_receivables' AS table_name,'updated_at' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'sku' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'warehouse' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'unit' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'quantity' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'reserved' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'reorder_point' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'counted_date' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'source_note' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'active' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_pilot_stock' AS table_name,'updated_at' AS column_name
UNION ALL
SELECT 'wm_quote_costing' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_quote_costing' AS table_name,'quote_id' AS column_name
UNION ALL
SELECT 'wm_quote_costing' AS table_name,'currency' AS column_name
UNION ALL
SELECT 'wm_quote_costing' AS table_name,'quote_version' AS column_name
UNION ALL
SELECT 'wm_quote_costing' AS table_name,'material_cost' AS column_name
UNION ALL
SELECT 'wm_quote_costing' AS table_name,'production_cost' AS column_name
UNION ALL
SELECT 'wm_quote_costing' AS table_name,'logistics_cost' AS column_name
UNION ALL
SELECT 'wm_quote_costing' AS table_name,'notes' AS column_name
UNION ALL
SELECT 'wm_quote_costing' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_quote_costing' AS table_name,'updated_at' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'lead_id' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'reference' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'title' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'owner_id' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'currency' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'address' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'notes' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'status' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'planned_transport_cost' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'actual_sample_cost' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'actual_transport_cost' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'revision' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'commercial_by' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'commercial_at' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'director_by' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'director_at' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'prepared_by' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'prepared_at' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'sent_date' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'carrier' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'tracking_ref' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'shipping_note' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'received_date' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'receiver_name' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'receipt_note' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'followup_due_date' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'followup_date' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'followup_note' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'created_by' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_samples' AS table_name,'updated_at' AS column_name
UNION ALL
SELECT 'wm_sample_access' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_sample_access' AS table_name,'user_id' AS column_name
UNION ALL
SELECT 'wm_sample_access' AS table_name,'role' AS column_name
UNION ALL
SELECT 'wm_sample_access' AS table_name,'granted_by' AS column_name
UNION ALL
SELECT 'wm_sample_allocations' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_sample_allocations' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_sample_allocations' AS table_name,'sample_id' AS column_name
UNION ALL
SELECT 'wm_sample_allocations' AS table_name,'item_id' AS column_name
UNION ALL
SELECT 'wm_sample_allocations' AS table_name,'lot_id' AS column_name
UNION ALL
SELECT 'wm_sample_allocations' AS table_name,'stock_id' AS column_name
UNION ALL
SELECT 'wm_sample_allocations' AS table_name,'quantity' AS column_name
UNION ALL
SELECT 'wm_sample_allocations' AS table_name,'status' AS column_name
UNION ALL
SELECT 'wm_sample_allocations' AS table_name,'stock_snapshot' AS column_name
UNION ALL
SELECT 'wm_sample_allocations' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_sample_conversions' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_sample_conversions' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_sample_conversions' AS table_name,'order_id' AS column_name
UNION ALL
SELECT 'wm_sample_conversions' AS table_name,'sample_id' AS column_name
UNION ALL
SELECT 'wm_sample_conversions' AS table_name,'status' AS column_name
UNION ALL
SELECT 'wm_sample_conversions' AS table_name,'attribution_bps' AS column_name
UNION ALL
SELECT 'wm_sample_conversions' AS table_name,'source' AS column_name
UNION ALL
SELECT 'wm_sample_conversions' AS table_name,'evidence' AS column_name
UNION ALL
SELECT 'wm_sample_conversions' AS table_name,'confirmed_by' AS column_name
UNION ALL
SELECT 'wm_sample_conversions' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_sample_conversions' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_sample_conversions' AS table_name,'updated_at' AS column_name
UNION ALL
SELECT 'wm_sample_events' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_sample_events' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_sample_events' AS table_name,'sample_id' AS column_name
UNION ALL
SELECT 'wm_sample_events' AS table_name,'event_type' AS column_name
UNION ALL
SELECT 'wm_sample_events' AS table_name,'staff_id' AS column_name
UNION ALL
SELECT 'wm_sample_events' AS table_name,'account_id' AS column_name
UNION ALL
SELECT 'wm_sample_events' AS table_name,'note' AS column_name
UNION ALL
SELECT 'wm_sample_events' AS table_name,'payload_json' AS column_name
UNION ALL
SELECT 'wm_sample_events' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'sample_id' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'revision' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'active' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'product_id' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'sku' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'label' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'unit' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'size_text' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'color_text' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'logo_text' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'quantity' AS column_name
UNION ALL
SELECT 'wm_sample_items' AS table_name,'planned_unit_cost' AS column_name
UNION ALL
SELECT 'wm_sample_lots' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_sample_lots' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_sample_lots' AS table_name,'stock_id' AS column_name
UNION ALL
SELECT 'wm_sample_lots' AS table_name,'size_text' AS column_name
UNION ALL
SELECT 'wm_sample_lots' AS table_name,'color_text' AS column_name
UNION ALL
SELECT 'wm_sample_lots' AS table_name,'quantity' AS column_name
UNION ALL
SELECT 'wm_sample_lots' AS table_name,'reserved' AS column_name
UNION ALL
SELECT 'wm_sample_lots' AS table_name,'counted_date' AS column_name
UNION ALL
SELECT 'wm_sample_lots' AS table_name,'source_note' AS column_name
UNION ALL
SELECT 'wm_sample_lots' AS table_name,'active' AS column_name
UNION ALL
SELECT 'wm_sample_lots' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_sample_order_facts' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_sample_order_facts' AS table_name,'order_id' AS column_name
UNION ALL
SELECT 'wm_sample_order_facts' AS table_name,'order_date' AS column_name
UNION ALL
SELECT 'wm_sample_order_facts' AS table_name,'currency' AS column_name
UNION ALL
SELECT 'wm_sample_order_facts' AS table_name,'revenue_ht' AS column_name
UNION ALL
SELECT 'wm_sample_order_facts' AS table_name,'variable_cost_ht' AS column_name
UNION ALL
SELECT 'wm_sample_order_facts' AS table_name,'items_json' AS column_name
UNION ALL
SELECT 'wm_sample_order_facts' AS table_name,'source_note' AS column_name
UNION ALL
SELECT 'wm_sample_order_facts' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_sample_stock_events' AS table_name,'id' AS column_name
UNION ALL
SELECT 'wm_sample_stock_events' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_sample_stock_events' AS table_name,'stock_id' AS column_name
UNION ALL
SELECT 'wm_sample_stock_events' AS table_name,'lot_id' AS column_name
UNION ALL
SELECT 'wm_sample_stock_events' AS table_name,'sample_id' AS column_name
UNION ALL
SELECT 'wm_sample_stock_events' AS table_name,'event_type' AS column_name
UNION ALL
SELECT 'wm_sample_stock_events' AS table_name,'before_json' AS column_name
UNION ALL
SELECT 'wm_sample_stock_events' AS table_name,'after_json' AS column_name
UNION ALL
SELECT 'wm_sample_stock_events' AS table_name,'staff_id' AS column_name
UNION ALL
SELECT 'wm_sample_stock_events' AS table_name,'created_at' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'org_id' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'lead_id' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'wearer_count' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'garments' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'ppe' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'standards' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'sizing' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'branding' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'renewal' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'supplier' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'constraints_text' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'version' AS column_name
UNION ALL
SELECT 'wm_workwear_profiles' AS table_name,'updated_at' AS column_name) e JOIN information_schema.tables t ON t.table_schema=DATABASE() AND t.table_name=e.table_name
LEFT JOIN information_schema.columns c ON c.table_schema=DATABASE() AND c.table_name=e.table_name AND c.column_name=e.column_name WHERE c.column_name IS NULL;
-- Comparer AUSSI types, valeurs par défaut, clés et index aux migrations.
-- Aucun contrôle ci-dessous ne répare une structure existante.
SELECT table_name,column_name,column_type,is_nullable,column_default,extra FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name IN (
'wm_crm_contacts','wm_workwear_profiles','wm_quote_costing','wm_b2b_accounts','wm_b2b_orders','wm_b2b_documents','wm_b2b_bat_decisions','wm_b2b_quotes','wm_b2b_threads','wm_b2b_messages','wm_pilot_access','wm_pilot_client_meta','wm_pilot_opportunity_meta','wm_pilot_stock','wm_pilot_receivables','wm_pilot_hr_snapshots','wm_pilot_actions','wm_sample_access','wm_samples','wm_sample_items','wm_sample_lots','wm_sample_allocations','wm_sample_events','wm_sample_stock_events','wm_sample_order_facts','wm_sample_conversions') ORDER BY table_name,ordinal_position;
-- Repères avant/après. Sauvegarder TOUTE la base séparément.
SELECT 'prospects' AS categorie,COUNT(*) AS nombre FROM wm_leads
UNION ALL SELECT 'comptes',COUNT(*) FROM wm_users
UNION ALL SELECT 'historique',COUNT(*) FROM wm_interactions
UNION ALL SELECT 'opportunites',COUNT(*) FROM wm_opportunities
UNION ALL SELECT 'devis',COUNT(*) FROM wm_quotes
UNION ALL SELECT 'fournisseurs',COUNT(*) FROM wm_suppliers;
