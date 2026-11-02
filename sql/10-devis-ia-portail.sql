-- WORKMAN 1.11.0-rc1 : module 6 + module 7, base 1.10.0-rc1.
-- Tables nouvelles uniquement. Aucun changement aux lignes existantes.
CREATE TABLE IF NOT EXISTS wm_quote_costing (
 org_id BIGINT UNSIGNED NOT NULL, quote_id BIGINT UNSIGNED NOT NULL,
 currency ENUM('TND','EUR','USD') NOT NULL, quote_version INT UNSIGNED NOT NULL,
 material_cost DECIMAL(15,3) NULL, production_cost DECIMAL(15,3) NULL, logistics_cost DECIMAL(15,3) NULL,
 notes TEXT NOT NULL, version INT UNSIGNED NOT NULL DEFAULT 1,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 PRIMARY KEY(org_id,quote_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_b2b_accounts (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, org_id BIGINT UNSIGNED NOT NULL, lead_id BIGINT UNSIGNED NOT NULL,
 login_code CHAR(16) NOT NULL, email VARCHAR(254) NOT NULL, full_name VARCHAR(200) NOT NULL,
 password_hash VARCHAR(255) NOT NULL, active TINYINT UNSIGNED NOT NULL DEFAULT 1,
 must_change TINYINT UNSIGNED NOT NULL DEFAULT 1, auth_version INT UNSIGNED NOT NULL DEFAULT 1,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY login_code(login_code), UNIQUE KEY client_email(org_id,lead_id,email), KEY org_lead(org_id,lead_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_b2b_orders (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, org_id BIGINT UNSIGNED NOT NULL, lead_id BIGINT UNSIGNED NOT NULL,
 reference VARCHAR(80) NOT NULL, title VARCHAR(200) NOT NULL,
 status ENUM('confirmed','production','quality','ready','shipped','delivered','cancelled') NOT NULL DEFAULT 'confirmed',
 production_note TEXT NOT NULL, shipment_note TEXT NOT NULL, carrier VARCHAR(150) NOT NULL DEFAULT '',
 tracking_ref VARCHAR(200) NOT NULL DEFAULT '', estimated_delivery DATE NULL,
 version INT UNSIGNED NOT NULL DEFAULT 1, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY org_reference(org_id,reference), KEY org_lead(org_id,lead_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_b2b_documents (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, org_id BIGINT UNSIGNED NOT NULL, lead_id BIGINT UNSIGNED NOT NULL,
 order_id BIGINT UNSIGNED NULL, kind ENUM('bat','invoice','other') NOT NULL,
 title VARCHAR(200) NOT NULL, file_name VARCHAR(200) NOT NULL,
 pdf_base64 MEDIUMTEXT NOT NULL, sha256 CHAR(64) NOT NULL, visible TINYINT UNSIGNED NOT NULL DEFAULT 1,
 bat_status ENUM('pending','approved','rejected','superseded','not_bat') NOT NULL,
 replaces_id BIGINT UNSIGNED NULL, version INT UNSIGNED NOT NULL DEFAULT 1,
 created_by BIGINT UNSIGNED NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 KEY org_lead(org_id,lead_id), KEY org_order(org_id,order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_b2b_bat_decisions (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, org_id BIGINT UNSIGNED NOT NULL, lead_id BIGINT UNSIGNED NOT NULL,
 document_id BIGINT UNSIGNED NOT NULL, account_id BIGINT UNSIGNED NOT NULL,
 decision ENUM('approved','rejected') NOT NULL, sha256 CHAR(64) NOT NULL, note TEXT NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, UNIQUE KEY document_id(document_id), KEY org_lead(org_id,lead_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_b2b_quotes (
 org_id BIGINT UNSIGNED NOT NULL, lead_id BIGINT UNSIGNED NOT NULL, quote_id BIGINT UNSIGNED NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY(org_id,quote_id), KEY org_lead(org_id,lead_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_b2b_threads (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, org_id BIGINT UNSIGNED NOT NULL, lead_id BIGINT UNSIGNED NOT NULL,
 kind ENUM('message','complaint') NOT NULL, subject VARCHAR(200) NOT NULL,
 status ENUM('open','resolved') NOT NULL DEFAULT 'open', version INT UNSIGNED NOT NULL DEFAULT 1,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, KEY org_lead(org_id,lead_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS wm_b2b_messages (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, org_id BIGINT UNSIGNED NOT NULL, lead_id BIGINT UNSIGNED NOT NULL,
 thread_id BIGINT UNSIGNED NOT NULL, account_id BIGINT UNSIGNED NULL, staff_id BIGINT UNSIGNED NULL,
 message TEXT NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 KEY thread_messages(org_id,thread_id,id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
