PoliticalActionType.destroy_all

pat_path = './engines/vassals_and_robbers/db/seeds/pat_nobles_vassals.csv'


f = File.open(pat_path, 'r+')
f.gets #headers
while str = f.gets
  job_name, name, action, icon, desc, prob, cost, success, failure = str.split(";").map{|i| i.strip}
  job = Job.find_by_name(job_name)
  PoliticalActionType.create(
    icon: icon, name: name, action: action, job: job,
    description: desc, cost: cost, probability: prob, 
    success: success, failure: failure)
end