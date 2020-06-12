require 'rbvmomi'
class VMware < Oxidized::Model
    cmd "/" do |cfg|
      vim = RbVmomi::VIM.connect host: @node.vcenter, 
                                  ssl: @node.tls, 
                             insecure: @node.insecure,
                                 user: @node.auth[:username],
                             password: @node.auth[:password] 

      dc = vim.serviceInstance.find_datacenter(@node.dc) or abort "datacenter not found"
      host = dc.hostFolder.children.find(@node.name).first

      uri = 
        begin
          configManager.firmwareSystem.BackupFirmwareConfiguration_Task().wait_for_completion
          diagMgr.GenerateLogBundles_Task(includeDefault: true).wait_for_completion
        rescue VIM::TaskInProgress
          $!.task.wait_for_completion
        end
      tgz = uri
  
  cfg :http do
    @secure = true
  end  
end
