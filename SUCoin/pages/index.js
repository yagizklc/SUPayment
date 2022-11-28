import * as React from 'react';
import { styled, AppBar, Box, Toolbar, Container, Typography, Button } from '@mui/material';
import Image from 'next/image';
import Head from 'next/head';
import logo from '../public/logo.png';

const navItems = ['Home', 'About', 'Contact'];
const StyledToolbar = styled(Toolbar)(({ theme }) => ({
  alignItems: 'flex-center',
  // Override media queries injected by theme.mixins.toolbar
  '@media all': {
    minHeight: 86,
  },
}));


function DrawerAppBar(props) {
  return (
    <Box sx={{ display: 'flex' }}>
      <Head>
        <title>SUFriends</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <AppBar component="nav" color='transparent' >
        <Container>
          <StyledToolbar>
            <Image
              alt="Logo"
              src={logo}
              placeholder="blur"
              width={200}
            />
            <Box sx={{ ml: 2, mt: 1}}>
              {navItems.map((item) => (
                <Button key={item} sx={{ mx: 1}} variant="text" size='large'>
                  {item}
                </Button>
              ))}
            </Box>
          </StyledToolbar>
        </Container>
      </AppBar>
      <Container component="main" sx={{ p: 3 }}>
        <Toolbar />
        <Typography>
          Lorem ipsum dolor sit amet consectetur adipisicing elit. Similique unde
          fugit veniam eius, perspiciatis sunt? Corporis qui ducimus quibusdam,
          aliquam dolore excepturi quae. Distinctio enim at eligendi perferendis in
          cum quibusdam sed quae, accusantium et aperiam? Quod itaque exercitationem,
          at ab sequi qui modi delectus quia corrupti alias distinctio nostrum.
          Minima ex dolor modi inventore sapiente necessitatibus aliquam fuga et. Sed
          numquam quibusdam at officia sapiente porro maxime corrupti perspiciatis
          asperiores, exercitationem eius nostrum consequuntur iure aliquam itaque,
          assumenda et! Quibusdam temporibus beatae doloremque voluptatum doloribus
          soluta accusamus porro reprehenderit eos inventore facere, fugit, molestiae
          ab officiis illo voluptates recusandae. Vel dolor nobis eius, ratione atque
          soluta, aliquam fugit qui iste architecto perspiciatis. Nobis, voluptatem!
          Cumque, eligendi unde aliquid minus quis sit debitis obcaecati error,
          delectus quo eius exercitationem tempore. Delectus sapiente, provident
          corporis dolorum quibusdam aut beatae repellendus est labore quisquam
          praesentium repudiandae non vel laboriosam quo ab perferendis velit ipsa
          deleniti modi! Ipsam, illo quod. Nesciunt commodi nihil corrupti cum non
          fugiat praesentium doloremque architecto laborum aliquid. Quae, maxime
          recusandae? Eveniet dolore molestiae dicta blanditiis est expedita eius
          debitis cupiditate porro sed aspernatur quidem, repellat nihil quasi
          praesentium quia eos, quibusdam provident. Incidunt tempore vel placeat
          voluptate iure labore, repellendus beatae quia unde est aliquid dolor
          molestias libero. Reiciendis similique exercitationem consequatur, nobis
          placeat illo laudantium! Enim perferendis nulla soluta magni error,
          provident repellat similique cupiditate ipsam, et tempore cumque quod! Qui,
          iure suscipit tempora unde rerum autem saepe nisi vel cupiditate iusto.
          Illum, corrupti? Fugiat quidem accusantium nulla. Aliquid inventore commodi
          reprehenderit rerum reiciendis! Quidem alias repudiandae eaque eveniet
          cumque nihil aliquam in expedita, impedit quas ipsum nesciunt ipsa ullam
          consequuntur dignissimos numquam at nisi porro a, quaerat rem repellendus.
          Voluptates perspiciatis, in pariatur impedit, nam facilis libero dolorem
          dolores sunt inventore perferendis, aut sapiente modi nesciunt.
        </Typography>
      </Container>
    </Box>
  );
}

export default DrawerAppBar;
