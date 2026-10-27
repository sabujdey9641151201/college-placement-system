const test=require('node:test'),assert=require('node:assert/strict');const {isEligible}=require('../src/lib/eligibility');
const student={cgpa:8.2,department:'Computer Science',graduation_year:2027};const drive={status:'published',deadline:'2030-01-01T00:00:00Z',min_cgpa:7,graduation_year:2027,allowed_departments:'Computer Science, Electrical'};
test('eligible when batch, CGPA, department and deadline match',()=>assert.equal(isEligible(student,drive,new Date('2029-01-01')),true));
test('rejects below minimum CGPA',()=>assert.equal(isEligible({...student,cgpa:6.9},drive),false));
test('department matching ignores case and whitespace',()=>assert.equal(isEligible(student,{...drive,allowed_departments:' computer science '}),true));
test('rejects wrong graduation year, closed drives and expired deadlines',()=>{assert.equal(isEligible(student,{...drive,graduation_year:2028}),false);assert.equal(isEligible(student,{...drive,status:'closed'}),false);assert.equal(isEligible(student,{...drive,deadline:'2020-01-01'}),false)});
test('missing CGPA cannot pass the check',()=>assert.equal(isEligible({...student,cgpa:null},drive),false));
