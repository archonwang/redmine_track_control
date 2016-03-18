require 'redmine_track_control/tracker_helper'

module RedmineTrackControl
  
  module QueryPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        alias_method_chain :trackers, :trackcontrol
      end
    end
    
    #      def trackers
    #    @trackers ||= project.nil? ? Tracker.sorted.to_a : project.rolled_up_trackers
    #  end

    module InstanceMethods
      def trackers_with_trackcontrol  
        if project.nil? || !RedmineTrackControl::TrackerHelper.is_trackcontrol_enabled(project)
          trackers_without_trackcontrol
        else
          all_prjs = [project] 
          if !project.children.nil?
            all_prjs |= project.children.visible.to_a
          end
          @trackers = []
          all_prjs.each do |prj|
            @trackers |= Tracker.where(:id => RedmineTrackControl::TrackerHelper.valid_trackers_ids_incl_assigned_to(prj, "show")).order("#{Tracker.table_name}.position")              
          end             
          @trackers = @trackers.compact.reject(&:blank?).uniq.sort  
        end
      end
    end
  end
end
