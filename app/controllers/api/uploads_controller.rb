require "zip"

class Api::UploadsController < ActionController::Base
    def upload
      if params[:backup_name].present?
        backup_folder = Rails.root.join('data', params[:backup_name])
        FileUtils.mkdir_p(backup_folder)

        cpFiles_folder = Rails.root.join('tmpCpFiles', params[:backup_name])
        
        params[:files].each do |uploaded_file|
          file_path = File.join(backup_folder, uploaded_file.original_filename)

          if File.exist?(file_path)
            # Se o arquivo já existe na pasta de backup, verifique a data de modificação.
            existing_mtime = File.mtime(file_path)
            new_mtime = File.mtime(uploaded_file.tempfile)
            
            if existing_mtime != new_mtime and params[:overwrite]=='true'
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
      end
      redirect_to action: 'list'
    end 
    def list
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
  
      @folders = folder_info
    end

    def delete
      # Verifique se o parâmetro 'backup_name' foi enviado na solicitação.
      if params[:backup_name].present?
        backup_folder = Rails.root.join('data', params[:backup_name])
  
        # Verifique se a pasta de backup existe.
        if File.exist?(backup_folder)
          # Exclua a pasta de backup e seu conteúdo.
          FileUtils.rm_rf(backup_folder)
          redirect_to action: 'list'
        else
          redirect_to action: 'list'
        end
      else
        redirect_to action: 'list'
      end
    end

    def download
      backup_name = params[:backup_name]
  
      if backup_name.present?
        backup_folder = Rails.root.join('data', backup_name)
        zip_filename = "#{backup_name}.zip"
        zip_file_path = Rails.root.join('data', zip_filename)
  
        if File.directory?(backup_folder)

          # Remova o arquivo .zip existente, se existir.
          File.delete(zip_file_path) if File.exist?(zip_file_path)

          # Crie um arquivo .zip diretamente na pasta de backup.
          Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
            Dir[File.join(backup_folder, '**', '**')].each do |file|
              relative_path = file.sub("#{backup_folder}/", '')
              zipfile.add(relative_path, file)
            end
          end
  
          # Configure o cabeçalho de resposta Content-Disposition para forçar o download.
          send_file zip_file_path, type: 'application/zip', filename: zip_filename, disposition: 'attachment'
        else
          render json: { error: "O backup #{backup_name} não foi encontrado." }, status: :not_found
        end
      else
        render json: { error: 'O parâmetro "backup_name" é obrigatório.' }, status: :unprocessable_entity
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
