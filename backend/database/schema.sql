CREATE DATABASE IF NOT EXISTS placement_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE placement_db;

CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(100) NOT NULL,
  role ENUM('student','tpo','recruiter') NOT NULL,
  token_version INT UNSIGNED NOT NULL DEFAULT 0,  -- bumping this revokes every issued JWT
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS students (
  user_id INT UNSIGNED PRIMARY KEY,
  roll_no VARCHAR(30) NOT NULL UNIQUE,
  department VARCHAR(80) NOT NULL,
  graduation_year SMALLINT UNSIGNED NOT NULL,
  cgpa DECIMAL(3,2) NULL,
  phone VARCHAR(20) NULL,
  resume_path VARCHAR(255) NULL,
  resume_original_name VARCHAR(255) NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS companies (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  website VARCHAR(255) NULL,
  description TEXT NULL,
  created_by INT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);
CREATE TABLE IF NOT EXISTS recruiters (
  user_id INT UNSIGNED PRIMARY KEY,
  company_id INT UNSIGNED NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (company_id) REFERENCES companies(id)
);
CREATE TABLE IF NOT EXISTS drives (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  company_id INT UNSIGNED NOT NULL,
  title VARCHAR(150) NOT NULL,
  description TEXT NULL,
  package_lpa DECIMAL(5,2) NULL,
  location VARCHAR(100) NULL,
  min_cgpa DECIMAL(3,2) NOT NULL DEFAULT 0,
  allowed_departments VARCHAR(255) NULL,           -- comma-separated; NULL = all
  graduation_year SMALLINT UNSIGNED NULL,          -- NULL = any batch
  deadline DATETIME NOT NULL,
  status ENUM('draft','published','closed') NOT NULL DEFAULT 'draft',
  created_by INT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (company_id) REFERENCES companies(id),
  FOREIGN KEY (created_by) REFERENCES users(id),
  INDEX idx_drives_status_deadline (status, deadline)
);
CREATE TABLE IF NOT EXISTS applications (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  drive_id INT UNSIGNED NOT NULL,
  student_id INT UNSIGNED NOT NULL,
  status ENUM('applied','under_review','shortlisted','interview','offered','rejected','withdrawn') NOT NULL DEFAULT 'applied',
  applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_drive_student (drive_id, student_id),   -- blocks duplicate applications
  FOREIGN KEY (drive_id) REFERENCES drives(id),
  FOREIGN KEY (student_id) REFERENCES students(user_id)
);
CREATE TABLE IF NOT EXISTS application_history (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  application_id INT UNSIGNED NOT NULL,
  old_status VARCHAR(20) NULL,
  new_status VARCHAR(20) NOT NULL,
  changed_by INT UNSIGNED NOT NULL,
  note VARCHAR(255) NULL,
  changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE,
  FOREIGN KEY (changed_by) REFERENCES users(id)
);
CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NULL, action VARCHAR(80) NOT NULL, entity_type VARCHAR(50) NOT NULL,
  entity_id BIGINT UNSIGNED NULL, details JSON NULL, ip_address VARCHAR(45) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_audit_created(created_at), INDEX idx_audit_entity(entity_type,entity_id)
);
CREATE TABLE IF NOT EXISTS migrations (
  version VARCHAR(100) PRIMARY KEY,
  applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
