class Api::UploadsController < ActionController::Base
    def upload
      if params[:backup_name].present?
        backup_folder = Rails.root.join('data', params[:backup_name])
        FileUtils.mkdir_p(backup_folder)

        params[:files].each do |uploaded_file|
          file_path = File.join(backup_folder, uploaded_file.original_filename)

          if File.exist?(file_path)
            # Se o arquivo já existe na pasta de backup, verifique a data de modificação.
            existing_mtime = File.mtime(file_path)
            new_mtime = File.mtime(uploaded_file.tempfile)
            
            if existing_mtime != new_mtime and params[:overwrite]=="true"
              # As datas de modificação são diferentes, sobrescreva o arquivo.
              File.open(file_path, 'wb') do |file|
                file.write(uploaded_file.read)
              end
            end
          else
            # O arquivo não existe na pasta de backup, crie-o.
            File.open(file_path, 'wb') do |file|
              file.write(uploaded_file.read)
            end
          end
        end

        render json: { message: 'Arquivos enviados com sucesso.' }
      else
        render json: { error: 'O nome do backup não foi fornecido.' }, status: :unprocessable_entity
      end
    end 
    def list_backups
      data_directory = Rails.root.join('data')
      folders = Dir.entries(data_directory).select { |entry| File.directory?(File.join(data_directory, entry)) && entry != '.' && entry != '..' }

      folder_info = []
      folders.each do |folder|
        folder_path = File.join(data_directory, folder)
        folder_info << {
          name: folder,
          size: folder_size(folder_path),
          created_at: File.ctime(folder_path),
          updated_at: File.mtime(folder_path)
        }
      end
  
      @folders = folder_infoz
      #render json: { folders: folder_info }
    end

    def delete_backup
      # Verifique se o parâmetro 'backup_name' foi enviado na solicitação.
      if params[:backup_name].present?
        backup_folder = Rails.root.join('data', params[:backup_name])
  
        # Verifique se a pasta de backup existe.
        if File.exist?(backup_folder)
          # Exclua a pasta de backup e seu conteúdo.
          FileUtils.rm_rf(backup_folder)
          render json: { message: 'Backup excluído com sucesso.' }
        else
          render json: { error: 'O backup não existe.' }, status: :not_found
        end
      else
        render json: { error: 'O nome do backup não foi fornecido.' }, status: :unprocessable_entity
      end
    end
  
    private
  
    def folder_size(path)
      total_size = 0
      Dir.glob(File.join(path, '**', '*')).each do |file|
        total_size += File.size(file) if File.file?(file)
      end
      # Converte o tamanho para uma unidade legível (KB, MB, GB, etc.)
      units = %w[Bytes KB MB GB TB PB EB ZB YB]
      i = 0
      while total_size >= 1024 && i < units.length - 1
        total_size /= 1024.0
        i += 1
      end
      "%.2f #{units[i]}" % total_size
    end
  end
end
