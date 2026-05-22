CREATE PROFILE profil_securite LIMIT
   PASSWORD_LIFE_TIME 90
   FAILED_LOGIN_ATTEMPTS 3
   PASSWORD_LOCK_TIME 1
   IDLE_TIME 30;

ALTER USER u_ventes PROFILE profil_securite;
ALTER USER u_stock PROFILE profil_securite;
ALTER USER u_admin PROFILE profil_securite;
ALTER USER client_demo PROFILE profil_securite;

SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile = 'PROFIL_SECURITE'
ORDER BY resource_name;

SELECT username, profile
FROM dba_users
WHERE username IN ('U_VENTES', 'U_STOCK', 'U_ADMIN', 'CLIENT_DEMO')
ORDER BY username;