#encoding: utf-8
module Vagabond
  module Actions
    module Thaw
      def _thaw
        name_required!
        if(lxc.exists?)
          if(lxc.frozen?)
            ui.info "#{ui.color('Vagabond:', :bold)} Thawing node: #{ui.color(name, :yellow)}"
            lxc.unfreeze
            ui.info ui.color('  -> THAWED!', :yellow)
          else
            ui.error "Node is not currently frozen: #{name}"
          end
        else
          ui.error "Node does not exist: #{name}"
        end
      end
    end
  end
end
