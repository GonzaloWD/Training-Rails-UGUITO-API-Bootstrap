module UtilityService
  module North
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['libros']) }
      end

      def retrieve_notes(_response_code, response_body)
        { notes: map_notes(response_body['notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['id'],
            title: book['titulo'],
            author: book['autor'],
            genre: book['genero'],
            image_url: book['imagen_url'],
            publisher: book['editorial'],
            year: book['año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|
          {
            title: note['titulo'],
            type: convert_types(note['tipo']),
            created_at: note['fecha_creacion'],
            user: user_details(note),
            book: book_details(note)
          }
        end
      end

      def convert_types(type)
        { resenia: 'review', critica: 'critique' }.fetch(type.to_sym, 'review')
      end

      def user_details(note)
        {
          email: note.dig('autor', 'datos_de_contacto', 'email'),
          first_name: note.dig('autor', 'datos_personales', 'nombre'),
          last_name: note.dig('autor', 'datos_personales', 'apellido')
        }
      end

      def book_details(note)
        {
          title: note.dig('libro', 'titulo'),
          author: note.dig('libro', 'autor'),
          genre: note.dig('libro', 'genero')
        }
      end
    end
  end
end
