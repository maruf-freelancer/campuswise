Delayed::Worker.destroy_failed_jobs = false      # default true
Delayed::Worker.sleep_delay         = 3          # default 5 sec.
Delayed::Worker.max_attempts        = 5          # default 25
Delayed::Worker.max_run_time        = 60.minutes # default 4.hours
Delayed::Worker.read_ahead          = 15         # default 5

Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
if Delayed::Worker.logger.respond_to? :auto_flushing=
  Delayed::Worker.logger.auto_flushing = true
end
