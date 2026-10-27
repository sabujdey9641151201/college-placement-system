const db=require('../db');
module.exports=async function audit(userId,action,entityType,entityId,details={},req){try{await db.execute('INSERT INTO audit_logs(user_id,action,entity_type,entity_id,details,ip_address) VALUES(?,?,?,?,?,?)',[userId||null,action,entityType,entityId||null,JSON.stringify(details),req?.ip||null]);}catch(e){console.error('Audit log failed:',e.message)}};
