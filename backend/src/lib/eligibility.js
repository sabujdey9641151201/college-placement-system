function isEligible(student,drive,now=new Date()){
  if(!student||!drive||drive.status!=='published'||new Date(drive.deadline)<=now)return false;
  if(student.cgpa===null||student.cgpa===undefined||Number(student.cgpa)<Number(drive.min_cgpa))return false;
  if(drive.graduation_year&&Number(drive.graduation_year)!==Number(student.graduation_year))return false;
  if(drive.allowed_departments){const allowed=String(drive.allowed_departments).split(',').map(x=>x.trim().toLowerCase());if(!allowed.includes(String(student.department).trim().toLowerCase()))return false}
  return true;
}
module.exports={isEligible};
