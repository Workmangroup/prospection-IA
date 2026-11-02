-- WORKMAN 1.13.0-rc1 : gestion des échantillons.
-- Tables nouvelles uniquement. Aucun mouvement de stock ni migration de données historiques.
CREATE TABLE IF NOT EXISTS wm_sample_access (
 org_id BIGINT UNSIGNED NOT NULL,user_id BIGINT UNSIGNED NOT NULL,
 role ENUM('sales','director','logistics') NOT NULL,granted_by BIGINT UNSIGNED NOT NULL,
 PRIMARY KEY(org_id,user_id,role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_samples (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,org_id BIGINT UNSIGNED NOT NULL,lead_id BIGINT UNSIGNED NOT NULL,
 reference VARCHAR(40) NULL,title VARCHAR(200) NOT NULL,owner_id BIGINT UNSIGNED NULL,
 currency ENUM('TND','EUR','USD') NOT NULL,address TEXT NOT NULL,notes TEXT NOT NULL,
 status ENUM('requested','commercial_approved','approved','preparing','ready','shipped','received','followup','closed','rejected','cancelled') NOT NULL DEFAULT 'requested',
 planned_transport_cost DECIMAL(15,3) NULL,actual_sample_cost DECIMAL(15,3) NULL,actual_transport_cost DECIMAL(15,3) NULL,
 revision INT UNSIGNED NOT NULL DEFAULT 1,version INT UNSIGNED NOT NULL DEFAULT 1,
 commercial_by BIGINT UNSIGNED NULL,commercial_at DATETIME NULL,director_by BIGINT UNSIGNED NULL,director_at DATETIME NULL,
 prepared_by BIGINT UNSIGNED NULL,prepared_at DATETIME NULL,sent_date DATE NULL,
 carrier VARCHAR(150) NOT NULL DEFAULT '',tracking_ref VARCHAR(200) NOT NULL DEFAULT '',shipping_note TEXT NOT NULL,
 received_date DATE NULL,receiver_name VARCHAR(200) NOT NULL DEFAULT '',receipt_note TEXT NOT NULL,
 followup_due_date DATE NULL,followup_date DATE NULL,followup_note TEXT NOT NULL,
 created_by BIGINT UNSIGNED NOT NULL,created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY org_reference(org_id,reference),KEY org_lead(org_id,lead_id),KEY org_status(org_id,status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_sample_items (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,org_id BIGINT UNSIGNED NOT NULL,sample_id BIGINT UNSIGNED NOT NULL,
 revision INT UNSIGNED NOT NULL,active TINYINT UNSIGNED NOT NULL DEFAULT 1,product_id BIGINT UNSIGNED NOT NULL,
 sku VARCHAR(80) NOT NULL,label VARCHAR(200) NOT NULL,unit VARCHAR(30) NOT NULL,
 size_text VARCHAR(100) NOT NULL,color_text VARCHAR(100) NOT NULL,logo_text VARCHAR(1000) NOT NULL,
 quantity INT UNSIGNED NOT NULL,planned_unit_cost DECIMAL(15,3) NULL,
 KEY org_sample(org_id,sample_id,active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_sample_lots (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,org_id BIGINT UNSIGNED NOT NULL,stock_id BIGINT UNSIGNED NOT NULL,
 size_text VARCHAR(100) NOT NULL,color_text VARCHAR(100) NOT NULL,quantity INT UNSIGNED NOT NULL,reserved INT UNSIGNED NOT NULL DEFAULT 0,
 counted_date DATE NOT NULL,source_note VARCHAR(1000) NOT NULL,active TINYINT UNSIGNED NOT NULL DEFAULT 1,
 version INT UNSIGNED NOT NULL DEFAULT 1,UNIQUE KEY org_variant(org_id,stock_id,size_text,color_text)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_sample_allocations (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,org_id BIGINT UNSIGNED NOT NULL,sample_id BIGINT UNSIGNED NOT NULL,item_id BIGINT UNSIGNED NOT NULL,
 lot_id BIGINT UNSIGNED NOT NULL,stock_id BIGINT UNSIGNED NOT NULL,quantity INT UNSIGNED NOT NULL,
 status ENUM('reserved','released','shipped') NOT NULL,
 stock_snapshot TEXT NOT NULL,created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 KEY org_sample(org_id,sample_id,status),KEY org_stock(org_id,stock_id,status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_sample_events (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,org_id BIGINT UNSIGNED NOT NULL,sample_id BIGINT UNSIGNED NOT NULL,
 event_type VARCHAR(50) NOT NULL,staff_id BIGINT UNSIGNED NULL,account_id BIGINT UNSIGNED NULL,
 note TEXT NOT NULL,payload_json MEDIUMTEXT NOT NULL,created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 KEY org_sample(org_id,sample_id,id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_sample_stock_events (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,org_id BIGINT UNSIGNED NOT NULL,stock_id BIGINT UNSIGNED NOT NULL,
 lot_id BIGINT UNSIGNED NULL,sample_id BIGINT UNSIGNED NULL,event_type VARCHAR(30) NOT NULL,
 before_json TEXT NOT NULL,after_json TEXT NOT NULL,staff_id BIGINT UNSIGNED NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,KEY org_stock(org_id,stock_id,id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_sample_order_facts (
 org_id BIGINT UNSIGNED NOT NULL,order_id BIGINT UNSIGNED NOT NULL,order_date DATE NOT NULL,
 currency ENUM('TND','EUR','USD') NOT NULL,revenue_ht DECIMAL(15,3) NULL,variable_cost_ht DECIMAL(15,3) NULL,
 items_json TEXT NOT NULL,source_note VARCHAR(1000) NOT NULL,version INT UNSIGNED NOT NULL DEFAULT 1,
 PRIMARY KEY(org_id,order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_sample_conversions (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,org_id BIGINT UNSIGNED NOT NULL,order_id BIGINT UNSIGNED NOT NULL,
 sample_id BIGINT UNSIGNED NOT NULL,status ENUM('confirmed','rejected') NOT NULL,
 attribution_bps SMALLINT UNSIGNED NOT NULL DEFAULT 10000,source VARCHAR(30) NOT NULL,
 evidence TEXT NOT NULL,confirmed_by BIGINT UNSIGNED NOT NULL,version INT UNSIGNED NOT NULL DEFAULT 1,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY org_order(org_id,order_id),KEY org_sample(org_id,sample_id,status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
