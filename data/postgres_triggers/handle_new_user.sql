CREATE OR REPLACE FUNCTION public.handle_new_user()
    RETURNS TRIGGER
    AS $$
DECLARE
    full_name text;
    first_name text;
    last_name text;
    name_parts text[];
BEGIN
    -- the Google provider doesn't include a full name in the raw_user_meta_data
    -- so we need to extract firstnam, lastname from the full name
    full_name := NEW.raw_user_meta_data ->> 'full_name';
    -- Split the full name into an array
    name_parts := string_to_array(full_name, ' ');
    -- Get the last name (last element of the array)
    last_name := name_parts[array_length(name_parts, 1)];
    -- Get the first name (everything except the last element)
    first_name := array_to_string(name_parts[1:array_length(name_parts, 1) - 1], ' ');
    INSERT INTO public.profiles(id, email, firstname, lastname)
        VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data ->> 'firstname', first_name, ''), COALESCE(NEW.raw_user_meta_data ->> 'lastname', last_name, ''));
    RETURN NEW;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER;

